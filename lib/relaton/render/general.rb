# frozen_string_literal: true

module Relaton
  module Render
    # Compatibility entry point (relaton-render#90).
    #
    # The v2 engine replaced the liquid/config/i18n machinery with the
    # template evaluator over CitationStyle instances
    # (Relaton::Render::Iso690). isodoc main's render-isodoc subclasses
    # this constant, so it must exist for all-git-main stacks to boot.
    # This facade delegates rendering to the v2 engine; the retired
    # options (config:, template overrides in liquid syntax) are ignored
    # with one warning — migrate to a CitationStyle instance, which
    # expresses everything the old config.yml did (see the citation
    # module in relaton-models).
    class General
      # The eref `style=` vocabulary metanorma-standoc validates against
      # (cleanup/xref.rb reads citetemplate.template_raw's keys) — the
      # 1.x default config's top-level citation styles.
      CITE_STYLES = %i[
        author_date author_date_br author date reference_tag title
        title_reference_tag short
      ].freeze

      CiteTemplate = Struct.new(:template_raw)

      def initialize(options = {})
        options = deep_symbolize(options)
        @lang = options[:language] || options[:lang] || "en"
        renderer_opts = { lang: @lang, script: options[:script] || "Latn",
                          labels: options[:i18nhash] || {} }
        # A flavor names its own CitationStyle instance (name or YAML path)
        options[:style] and renderer_opts[:style] = options[:style]
        @renderer = Iso690::Renderer.new(**renderer_opts)
        warn_general_config if options[:config]
      end

      def render(model, embedded: false, **opts)
        model = to_model(model)
        text =
          if model.respond_to?(:formattedref) && model.formattedref
            model.formattedref.content
          else
            @renderer.render(model, **opts)
          end
        embedded ? text : "<formattedref>#{text}</formattedref>"
      end

      def citation(model, **opts)
        @renderer.citation(to_model(model), **opts)
      end

      # isodoc's references rendering: renderings[id][:formattedref]
      # feeds the <formattedref> of every bibitem (isodoc
      # presentation_function/refs.rb).
      def render_all(bib, type: "author-date")
        items = facade_bibitems(bib) or return nil
        items.each_with_object({}).with_index do |(item, m), i|
          ref = begin
            @renderer.render(item)
          rescue ::Relaton::Render::Unrenderable
            next
          end
          m[item.id] = {
            id: item.id, ord: i,
            formattedref: terminate_reference(ref),
            citation: citation_renderings(item, ref),
          }
        end
      end

      # isodoc's styled citations consume these keys: the default is the
      # authoritative identifier; the short cite is the style's citation,
      # falling back to the reference rendering (the 1.x short-cite)
      FIRST_DELIM = "<span class='fmt-first-biblio-delim'/>"

      # A creator list alone (flavors' document-history name forms)
      def creator_names(item)
        @renderer.render_creators(to_model(item))
      end

      # render_all feeds the bibliography list: a reference not ending
      # in the biblio terminator takes one (the 1.x render1 behaviour;
      # single-item render stays verbatim)
      def terminate_reference(ref)
        return ref if ref.empty? || ref.rstrip.end_with?(".")

        "#{ref}."
      end

      def citation_renderings(item, ref)
        short = @renderer.citation(item)
        short = if short.empty?
                  @renderer.render_short(item, FIRST_DELIM)
                else
                  short
                end

        {
          full: ref,
          default: item.docidentifier.first&.content.to_s,
          short: short,
        }
      end

      # isodoc's pref_ref_code_parse reads
      # data[:authoritative_identifier] to build biblio-tag identifiers
      # (presentation_function/docid.rb). Returns [data, self] as the
      # 1.x signature did.
      def parse(doc)
        [{ authoritative_identifier: facade_docids(doc) }, self]
      end

      def citetemplate
        CiteTemplate.new(CITE_STYLES.to_h { |s| [s, ""] })
      end

      private

      # 1.x accepted a <references> XML string (isodoc strips namespaces
      # before building it) or a ready array of models.
      def facade_bibitems(bib)
        case bib
        when Array then bib
        when String
          require "moxml"
          root = Moxml.parse(bib).root
          return nil unless root&.name == "references"

          klass = facade_bibitem_class
          root.xpath("./bibitem").filter_map { |b| klass.from_xml(b.to_xml) }
        end
      end

      def facade_bibitem_class
        Relaton::Bib::Bibitem
      rescue NameError
        Relaton::Bib::Item
      end

      # 1.x Parse#authoritative_identifier semantics: the
      # primary/language cascade, the excluded types (URN, DOI, ISBN...)
      # dropped, and scoped ids (biblio-tag duplicates, IEEE trademark)
      # demoted within their type group. isodoc hands the live bibitem
      # node with the document's default namespace still attached, so the
      # element queries must be namespace-agnostic.
      EXCLUDED_ID_TYPES = %w(METANORMA METANORMA-ORDINAL AUTHOR-DATE TITLE
                             URN ISO-REFERENCE ISSN ISBN DOI).freeze

      def facade_docids(doc)
        node = doc
        unless node.respond_to?(:xpath)
          require "moxml"
          node = Moxml.parse(doc.to_s).root
        end
        return [] unless node

        ids = node.xpath("./*[local-name() = 'docidentifier']")
        ids = facade_scope_filter(ids)
        out = nil
        [
          ->(x) { x["language"] == @lang && x["primary"] },
          ->(x) { x["primary"] },
          ->(x) { x["language"] == @lang },
          ->(_x) { true },
        ].each do |p|
          out = ids.select do |x|
            p.call(x) && !EXCLUDED_ID_TYPES.include?(facade_id_type(x))
          end
          out.empty? or break
        end
        out.map { |x| x.text.strip }
      end

      def facade_id_type(id)
        t = id["type"] or return nil
        m = /\A(ISBN|ISSN)\..*/i.match(t) or return t.upcase
        m[1].upcase
      end

      def facade_scope_filter(ids)
        ids.detect { |i| i["scope"] } or return ids
        ids.group_by { |i| i["type"] }.flat_map do |type, group|
          grouped = group.group_by { |i| i["scope"] }
          if type == "IEEE" then grouped["trademark"] || grouped[nil] || []
          else grouped[nil] || []
          end
        end
      end

      # 1.x accepted string- and symbol-keyed options alike (the old
      # engine deep-symbolized via metanorma-utils); isodoc's bibrenderer
      # and every flavor still pass string keys.
      def deep_symbolize(value)
        case value
        when Hash then value.to_h { |k, v| [k.to_sym, deep_symbolize(v)] }
        when Array then value.map { |v| deep_symbolize(v) }
        else value
        end
      end

      # 1.x render/citation accepted a bibitem XML string; the Iso690
      # engine consumes model instances.
      def to_model(model)
        return model unless model.is_a?(String)

        klass = facade_bibitem_class
        klass.from_xml(model)
      end

      def warn_general_config
        return if General.config_warned

        General.config_warned = true
        warn "relaton-render: Relaton::Render::General is a compatibility " \
             "facade over the v2 engine; the liquid config option is " \
             "retired and ignored. Author a CitationStyle instance " \
             "(relaton-models citation module) for custom rendering."
      end

      class << self
        attr_accessor :config_warned
      end
    end
  end
end
