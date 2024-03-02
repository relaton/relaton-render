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
        simple_xml2hash(doc).merge(simple_or_host_xml2hash(doc, host))
          .merge(host_xml2hash(host))
          .merge(series_xml2hash(doc, host))
      end

      def simple_xml2hash(doc)
        creators, role = creatornames(doc)
        { type: type(doc), title: title(doc), extent_raw: extent(doc),
          size_raw: size(doc), uri_raw: uri(doc), doi: doi(doc),
          authoritative_identifier: authoritative_identifier(doc),
          other_identifier: other_identifier(doc),
          status: status(doc), creators: creators, role_raw: role }
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
        return {} unless series

        { series_formatted: series_formatted(series, doc),
          series_title: series_title(series, doc),
          series_abbr: series_abbr(series, doc),
          series_run: series_run(series, doc),
          series_num: series_num(series, doc),
          series_partnumber: series_partnumber(series, doc),
          series_place: series_place(series, doc),
          series_org: series_org(series, doc),
          series_dates: series_dates(series, doc) }
      end

      private

      def blank?(text)
        text.nil? || text.empty?
      end
    end
  end
end
