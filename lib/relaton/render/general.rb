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
        @lang = options[:language] || options[:lang] || "en"
        @renderer = Iso690::Renderer.new(
          lang: @lang,
          script: options[:script] || "Latn",
          labels: options[:i18nhash] || {},
        )
        warn_general_config if options[:config]
      end

      def render(model, **opts)
        @renderer.render(model, **opts)
      end

      def citation(model, **opts)
        @renderer.citation(model, **opts)
      end

      # isodoc's references rendering: renderings[id][:formattedref]
      # feeds the <formattedref> of every bibitem (isodoc
      # presentation_function/refs.rb).
      def render_all(bib, type: "author-date")
        items = facade_bibitems(bib) or return nil
        items.each_with_object({}).with_index do |(item, m), i|
          ref = @renderer.render(item)
          m[item.id] = {
            id: item.id, ord: i, formattedref: ref,
            citation: {
              full: ref,
              default: item.docidentifier.first&.content.to_s,
              short: @renderer.citation(item),
            },
          }
        end
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

      def facade_docids(doc)
        node = doc
        unless node.respond_to?(:xpath)
          require "moxml"
          node = Moxml.parse(doc.to_s).root
        end
        return [] unless node

        node.xpath("./docidentifier").map(&:text)
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
