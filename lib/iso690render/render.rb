require "nokogiri"
require "twitter_cldr"
require_relative "render_contributors"
require_relative "render_dates"
require_relative "parse"
require "liquid"

class Iso690Render
  def initialize(options)
    @template = Liquid::Template.parse(options[:template])
    @nametemplate = options[:nametemplate].map { |x| Liquid::Template.parse(x) }
    @lang = options[:language]
    @script = options[:script]
    @i18n = i18n(@lang, @script)
  end

  def i18n(lang, script)
    ::Isodoc::I18n.new(lang, script)
  end

  def render(bib, embedded: false)
    docxml = Nokogiri::XML(bib)
    docxml.remove_namespaces!
    parse(docxml.root, embedded: embedded)
  end

  def title(doc)
    doc&.at("./title")&.text
  end

  def medium(doc)
    doc&.at("./medium")&.text
  end

  def blank?(text)
    text.nil? || text.empty?
  end

  def edition(doc)
    x = doc.at("./edition")
    return "" unless x
    return x.text unless /^\d+$/.match? x.text

    x.text.to_i.localize.to_rbnf_s("SpelloutRules", "spellout-ordinal")
  end

  BIBLIO_PUBLISHER = "contributor[role/@type = 'publisher']/organization".freeze

  def place(doc)
    doc&.at("./place")&.text
  end

  def publisher(doc)
    doc&.at("./#{BIBLIO_PUBLISHER}/name")&.text
  end

  def series_extract(doc)
    doc.at("./series[@type = 'main']") || doc.at("./series[not(@type)]") ||
      doc.at("./series")
  end

  def series_title(doc)
    series_extract(doc)&.at("./title")&.text
  end

  def series_abbr(doc)
    series_extract(doc)&.at("./title")&.text
  end

  def series_num(doc)
    series_extract(doc)&.at("./number")&.text
  end

  def series_partnumber(doc)
    series_extract(doc)&.at("./partnumber")&.text
  end

  def series(doc, type)
    s = series_extract(doc)
    return "" unless s

    f = s.at("./formattedref") and return f.text
    t = series_title(doc)
    a = series_abbr(doc)
    n = series_num(doc)
    p = series_partnumber(doc)
    dn = doc.at("./docnumber")
    rev = doc&.at(".//edition")&.text&.sub(/^Revision /, "")
    ret = ""
    if t
      title = if included(type)
                wrap(t.text, " <em>",
                     "</em>")
              else
                wrap(t.text, " ", "")
              end
      ret += title
      ret += " (#{a.text.sub(/^NIST /, '')})" if a
    end
    if n || p
      ret += " #{n.text}" if n
      ret += ".#{p.text}" if p
    elsif dn && nist?(doc)
      ret += " #{dn.text}"
      ret += " Rev. #{rev}" if rev
    end
    ret
  end

  def standardidentifier(doc)
    doc.xpath("./docidentifier").each_with_object([]) do |id, ret|
      ret << id.text unless %w(metanorma ordinal).include? id["type"]
    end
  end

  def uri(doc)
    uri = doc.at("./uri[@type = 'doi']") || doc.at("./uri[@type = 'uri']") ||
      doc.at("./uri[@type = 'src']") || doc.at("./uri")
    uri&.text
  end

  def access_location(doc)
    s = doc.at("./accessLocation") or return ""
    s.text
  end

  def included(type)
    ["article", "inbook", "incollection", "inproceedings"].include? type
  end

  def wrap(text, startdelim = " ", enddelim = ".")
    return "" if blank?(text)

    "#{startdelim}#{text}#{enddelim}"
  end

  def type(doc)
    type = doc.at("./@type") and return type&.text
    doc.at("./includedIn") and return "inbook"
    "book"
  end

  def extent2(type, from, upto)
    ret = ""
    case type
    when "page" then type = upto ? "pp." : "p."
    when "volume" then type = upto ? "Vols." : "Vol."
    end
    ret += "#{type} "
    ret += from.text if from
    ret += "&ndash;#{upto.text}" if upto
    ret
  end

  def extent1(localities)
    ret = []
    localities.each do |l|
      ret << extent2(l["type"] || "page",
                     l.at("./referenceFrom"), l.at("./referenceTo"))
    end
    ret.join(", ")
  end

  def extent(doc)
    ret = []
    ret1 = ""
    doc.xpath("./extent").each do |l|
      if %w(localityStack).include? l.name
        ret << ret1
        ret1 = ""
        ret << extent1(l.children)
      else ret1 += extent1([l])
      end
    end
    ret << ret1
    ret.reject(&:empty?).join("; ")
  end

  def draft(doc)
    dr = doc&.at("./status/stage")&.text

    iterord = iter_ordinal(doc)
    status = status_print(dr)
    status = "#{iterord} #{status}" if iterord
    status
  end

  def iter_ordinal(isoxml)
    return nil unless isoxml.at(("./status/iteration"))

    iter = isoxml.at(("./status/iteration"))&.text || "1"
    iter.to_i.localize.to_rbnf_s("SpelloutRules",
                                 "spellout-ordinal").capitalize
  end

  def status_print(status)
    status
  end

  def status(doc)
    doc&.at("./status/stage")&.text
  end
end
