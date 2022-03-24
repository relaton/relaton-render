require "nokogiri"
require "twitter_cldr"
require_relative "render_contributors"
require_relative "render_dates"
require_relative "render_classes"
require_relative "render_extract"
require "liquid"
require "isodoc-i18n"

class Iso690Render
  attr_reader :template

  def initialize(opt)
    @template = opt[:template]
    @nametemplate = opt[:nametemplate]
    @lang = opt[:lang]
    @script = opt[:script]
    @i18n = opt[:i18n]
  end

  def extract(doc)
    bib_xml2hash(doc).merge(series_xml2hash(doc)).merge(@i18n.get)
  end

  def bib_xml2hash(doc)
    { title: title(doc), edition: edition(doc), medium: medium(doc),
      place: place(doc), publisher: publisher(doc),
      standardidentifier: standardidentifier(doc), uri: uri(doc),
      access_location: access_location(doc), extent: extent(doc),
      status: status(doc), creatornames: creatornames(doc),
      date: date(doc), date_updated: date_updated(doc), type: type(doc) }
  end

  def series_xml2hash(doc)
    { series_title: series_title(doc), series_abbr: series_abbr(doc),
      series_num: series_num(doc), series_partnumber: series_partnumber(doc) }
  end
end
