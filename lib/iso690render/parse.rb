require "nokogiri"
require "twitter_cldr"
require_relative "parse_contributors"
require_relative "parse_dates"
require_relative "parse_extract"

class Iso690Parse
  def initialize; end

  def extract(doc)
    host = doc.at("./relation[@type = 'includedIn']/bibitem")
    series = doc.at("./series[@type = 'main']") ||
      doc.at("./series[not(@type)]") || doc.at("./series")
    simple_xml2hash(doc).merge(simple_or_host_xml2hash(doc, host))
      .merge(host_xml2hash(host))
      .merge(series_xml2hash(series))
  end

  def simple_xml2hash(doc)
    creators, role = creatornames(doc)
    { type: type(doc), title: title(doc), extent: extent(doc),
      standardidentifier: standardidentifier(doc), uri: uri(doc),
      status: status(doc), creators: creators, role: role }
  end

  def simple_or_host_xml2hash(doc, host)
    { edition: edition(doc, host), medium: medium(doc, host),
      place: place(doc, host), publisher: publisher(doc, host),
      access_location: access_location(doc, host),
      date: date(doc, host), date_updated: date_updated(doc, host) }
  end

  def host_xml2hash(host)
    creators, role = creatornames(host)
    { host_creators: creators, host_role: role, host_title: title(host) }
  end

  def series_xml2hash(series)
    return {} unless series

    { series_title: series_title(series), series_abbr: series_abbr(series),
      series_num: series_num(series),
      series_partnumber: series_partnumber(series) }
  end
end
