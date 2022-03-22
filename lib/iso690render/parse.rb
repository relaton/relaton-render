class Iso690Render
  def extract(doc)
    bib_xml2hash(doc).merge(series_xml2hash(doc)).merge(@i18n)
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

  def parse(doc, embedded: false)
    f = doc.at("./formattedref") and
      return embedded ? f.children.to_xml : doc.to_xml

    ret = parse1(doc)
    embedded and return ret
    "<formattedref>#{ret}</formattedref>#{doc.xpath('./docidentifier').to_xml}"
  end

  def parse1(doc)
    data = extract(doc).map { |k, v| [k.to_s, empty2nil(v)] }.to_h
    template_clean(@template.render(data))
  end

  # \u0018 signals empty field
  def empty2nil(str)
    return "\u0018" if str.nil?
    return "\u0018" if !str.nil? && str.is_a?(String) && str.empty?

    str
  end

  def template_clean(str)
    str.gsub(/\S*\u0018\S*/, "").gsub(/_/, " ").strip.sub(/^\s*\|./, "")
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
