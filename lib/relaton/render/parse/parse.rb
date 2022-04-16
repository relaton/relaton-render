require "nokogiri"
require "twitter_cldr"
require_relative "parse_contributors"
require_relative "parse_extract"

module Relaton
  module Render
    class Parse
      def initialize; end

      def extract(doc)
        host = host(doc)
        simple_xml2hash(doc).merge(simple_or_host_xml2hash(doc, host))
          .merge(host_xml2hash(host))
          .merge(series_xml2hash(doc, host))
      end

      def simple_xml2hash(doc)
        creators, role = creatornames(doc)
        { type: type(doc), title: title(doc), extent_raw: extent(doc),
          size_raw: size(doc),
          standardidentifier: standardidentifier(doc), uri: uri(doc),
          status: status(doc), creators: creators, role_raw: role }
      end

      def simple_or_host_xml2hash(doc, host)
        { edition_raw: edition(doc, host), medium_raw: medium(doc, host),
          place_raw: place(doc, host), publisher_raw: publisher(doc, host),
          distributor_raw: distributor(doc, host), draft_raw: draft(doc, host),
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
        series_xml2hash1(series)
      end

      def series_xml2hash1(series)
        return {} unless series

        { series_title: series_title(series), series_abbr: series_abbr(series),
          series_run: series_run(series), series_num: series_num(series),
          series_partnumber: series_partnumber(series) }
      end
    end
  end
end
