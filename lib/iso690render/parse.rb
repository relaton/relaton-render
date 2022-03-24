require_relative "render"

class Iso690Parse
  def initialize(opt)
    @i18n = i18n(opt[:language], opt[:script])
    @render = Iso690Render::BIBTYPE.each_with_object({}) do |t, m|
      m[t] = renderer(opt, t)
    end
  end

  def renderer(opt, type)
    template = opt[:template][type] || opt[:template][:misc] ||
      DEFAULT_TEMPLATE
    Iso690Render.subclass(type).new(
      template: Liquid::Template.parse(template),
      nametemplate: opt[:nametemplate].map { |x| Liquid::Template.parse(x) },
      lang: opt[:language], script: opt[:script], i18n: @i18n
    )
  end

  DEFAULT_TEMPLATE = "{{creatornames}}. {{title}}.".freeze

  def i18n(lang = "en", script = "Latn")
    ::IsoDoc::I18n.new(lang, script)
  end

  def render(bib, embedded: false)
    docxml = Nokogiri::XML(bib)
    docxml.remove_namespaces!
    parse(docxml.root, embedded: embedded)
  end

  def parse(doc, embedded: false)
    f = doc.at("./formattedref") and
      return embedded ? f.children.to_xml : doc.to_xml

    ret = parse1(doc)
    embedded and return ret
    "<formattedref>#{ret}</formattedref>"
  end

  def parse1(doc)
    r = @render[doc["type"].to_sym]
    data = r.extract(doc).map { |k, v| [k.to_s, empty2nil(v)] }.to_h
    template_clean(r.template.render(data))
  end

  # \u0018 signals empty field
  EMPTYFIELD = "\u0018".freeze

  def empty2nil(str)
    return EMPTYFIELD if str.nil?
    return EMPTYFIELD if !str.nil? && str.is_a?(String) && str.empty?

    str
  end

  def template_clean(str)
    str.gsub(/\S*#{EMPTYFIELD}\S*/o, "").gsub(/_/, " ").strip.sub(/^\s*\|./, "")
      .gsub(/(\|\S\s*)+(\|\S)/, "\\2").gsub(/\s*\|/, "")
  end

  # converting bibitem to <formattedref> + <docidentifier>
  def parse_old(doc, embedded: false)
    f = doc.at("./formattedref") and
      return embedded ? f.children.to_xml : doc.to_xml

    ret = ""
    type = type(doc)
    container = doc.at("./relation[@type='includedIn']")
    if container && !date(doc) && date(container&.at("./bibitem"))
      doc << (container&.at("./bibitem/date[@type = 'issued' or "\
                            "@type = 'published' or @type = 'circulated']")&.remove)
    end
    dr = draft(doc)
    cr = creatornames(doc)
    # NIST has seen fit to completely change rendering based on the type of publication.
    if series_title(doc) == "NIST Federal Information Processing Standards"
      cr = "National Institute of Standards and Technology"
    end
    pub = placepub(doc)

    ret += wrap(cr, "", "")
    if dr
      mdy = MMMddyyyy(date(doc)) and ret += wrap(mdy, " (", ")")
    else
      yr = year(date(doc)) and ret += wrap(yr, " (", ")")
    end
    ret += if included(type)
             wrap(title(doc), " ",
                  "")
           else
             wrap(title(doc), " <em>", "</em>")
           end
    ret += wrap(medium(doc), " [", "]")
    # ret += wrap(edition(doc), "", " edition.")
    cr != pub and ret += wrap(pub, " (", ")")
    if cr != pub && pub && !pub.empty? && (dr || !blank?(series(doc, type)))
      ret += ","
    end
    dr and ret += " Draft (#{dr})"
    ret += wrap(series(doc, type), " ", "")
    ret += wrap(date(doc), ", ", "")
    ret += wrap(standardidentifier(doc), ". ", "")
    ret += wrap(uri(doc), ". ", "")
    ret += wrap(access_location(doc), ". At: ", "")
    if container
      ret += wrap(parse(container.at("./bibitem"), true), ". In: ", "")
      locality = doc.xpath("./extent")
      ret += wrap(extent(locality), ", ", "")
    else
      ret += wrap(extent(doc.xpath("./extent")), ", ", "")
    end
    !embedded and ret += "."

    embedded ? ret : "<formattedref>#{ret}</formattedref>#{doc.xpath('./docidentifier').to_xml}"
  end
end
