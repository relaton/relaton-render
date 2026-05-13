require "nokogiri"
require "twitter_cldr"
require_relative "parse_contributors"
require_relative "parse_extract"
require_relative "parse_id"

module Relaton
  module Render
    class Parse
      def initialize(options)
        @lang = options[:lang] || "en"
        @script = options[:script] || "Latn"
        @i18n = options[:i18n]
      end

      def extract(doc)
        host = host(doc)
        ret = simple_xml2hash(doc).merge(simple_or_host_xml2hash(doc, host))
          .merge(host_xml2hash(host))
          .merge(series_xml2hash(doc, host))
        ret
        #i18n(ret)
      end

      def simple_xml2hash(doc)
        creators, role = creatornames(doc)
        { type: type(doc), title: title(doc), extent_raw: extent(doc),
          size_raw: size(doc), uri_raw: uri(doc), doi: doi(doc),
          authoritative_identifier: authoritative_identifier(doc),
          other_identifier_raw: other_identifier(doc), biblio_tag: biblio_tag(doc),
          status_raw: status(doc), creators: creators, role_raw: role,
          language: language(doc), script: script(doc), locale: locale(doc) }
      end

      def simple_or_host_xml2hash(doc, host)
        { edition_raw: edition(doc, host), edition_num: edition_num(doc, host),
          medium_raw: medium(doc, host), draft_raw: draft(doc, host),
          place_raw: place(doc, host), publisher_raw: publisher(doc, host),
          publisher_abbrev_raw: publisher_abbrev(doc, host),
          authorizer_raw: authorizer(doc, host),
          distributor_raw: distributor(doc, host),
          access_location: access_location(doc, host),
          date: date(doc, host), date_updated: date_updated(doc, host),
          date_accessed: date_accessed(doc, host) }
      end

      def host_xml2hash(host)
        creators, role = creatornames(host)
        { host_creators: creators, host_role_raw: role,
          host_title: title(host) }
      end

      def series_xml2hash(doc, host)
        series = series(doc)
        host and series ||= series(host)
        series_xml2hash1(series, doc)
      end

      def series_xml2hash1(series, doc)
        series or return {}
        ret = { series_formatted: series_formatted(series, doc),
                series_title: series_title(series, doc),
                series_abbr: series_abbr(series, doc),
                series_run: series_run(series, doc),
                series_num: series_num(series, doc),
                series_partnumber: series_partnumber(series, doc),
                series_place: series_place(series, doc),
                series_org: series_org(series, doc),
                series_dates: series_dates(series, doc) }
        ret.each do |k, v|
          %i(series_num series_dates).include?(k) and next
          ret[k] = esc(v)
        end
        ret
      end

      #KILL
      def other_identifier_i18n(hash)
           #ret << "#{type}: #{esc id.id}"
        hash[:other_identifier]&.map! do |i|
          i.include?("<esc>") ? @i18n.select(hash).l10n(i) : i
        end
      end

      ALLOWED_INLINE_TAGS = %w[
        em eref strong stem sub sup tt underline keyword ruby
        strike smallcap xref br link hr pagebreak bookmark
        image index index-xref concept add del span erefstack
        date fn
      ].freeze

      private

      def blank?(text)
        text.nil? || text.empty?
      end

      def esc(text)
        blank?(text) and return text
        "<esc>#{text}</esc>"
      end

      # Strip any tag not in ALLOWED_INLINE_TAGS, in both literal (<tag>) and
      # entity-encoded (&lt;tag&gt;) forms. Used to defend Liquid template
      # output against embedded structural markup (most commonly <title>) in
      # bibliographic text fields, where relaton-bib may surface either form
      # depending on lutaml-model serialisation behaviour.
      #
      # Authors embed inline markup either literally (<em>foo</em>) or
      # entity-encoded (&lt;em&gt;foo&lt;/em&gt;); both are intended as
      # markup, and downstream template rendering decodes entities anyway
      # (see HTMLEntities.decode in template.rb), so we normalise the
      # encoded form to literal up front and let a single Nokogiri-fragment
      # walk handle both. Elements whose name is in the allow-list are
      # preserved verbatim with their entire subtree, so wrappers that
      # legitimately carry block content (notably <fn><p>…</p></fn>)
      # round-trip intact rather than being shredded one tag at a time.
      # Disallowed elements are unwrapped (tag dropped, children kept),
      # recursing first so allowed wrappers nested inside disallowed
      # wrappers still survive. Nokogiri re-escapes any genuine `<` left in
      # text positions on serialisation, so plain prose like "5 < 10" is
      # preserved correctly.
      def sanitise_inline_markup(str)
        blank?(str) and return str
        normalised = str.gsub("&lt;", "<").gsub("&gt;", ">")
        frag = Nokogiri::XML.fragment(normalised)
        unwrap_disallowed(frag)
        save_opts = Nokogiri::XML::Node::SaveOptions::AS_XML |
                    Nokogiri::XML::Node::SaveOptions::NO_DECLARATION
        frag.to_xml(encoding: "UTF-8", save_with: save_opts)
      end

      def unwrap_disallowed(node)
        node.children.to_a.each do |child|
          next unless child.element?
          next if ALLOWED_INLINE_TAGS.include?(child.name)

          unwrap_disallowed(child)
          child.replace(child.children)
        end
      end

      def wrap_in_esc(obj)
        case obj
        when String then esc(obj)
        when Array then obj.map { |e| wrap_in_esc(e) }
        else obj
        end
      end
    end
  end
end
