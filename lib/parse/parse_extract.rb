class Iso690Parse
  def title(doc)
    doc&.at("./title")&.text
  end

  def medium(doc, host)
    x = doc.at("./medium") || host&.at("./medium") or return nil

    %w(content genre form carrier size scale).each_with_object([]) do |i, m|
      m << x.at("./#{i}")&.text
    end.compact.join(", ")
  end

  def blank?(text)
    text.nil? || text.empty?
  end

  def edition(doc, host)
    x = doc.at("./edition") || host&.at("./edition") or return nil

    x.text
  end

  BIBLIO_PUBLISHER = "contributor[role/@type = 'publisher']/organization".freeze

  def place(doc, host)
    x = doc.at("./place") || host&.at("./place") or return nil

    x.text
  end

  def publisher(doc, host)
    x = doc.at("./#{BIBLIO_PUBLISHER}/name") ||
      host&.at("./#{BIBLIO_PUBLISHER}/name") or return nil
    x.text
  end

  def series_title(doc)
    doc&.at("./title")&.text || doc&.at("./formattedref")&.text
  end

  def series_abbr(doc)
    doc&.at("./abbreviation")&.text
  end

  def series_num(doc)
    doc&.at("./number")&.text
  end

  def series_partnumber(doc)
    doc&.at("./partnumber")&.text
  end

  def series_run(doc)
    doc&.at("./run")&.text
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

  def access_location(doc, host)
    x = doc.at("./accessLocation") || host&.at("./accessLocation") or
      return nil
    x.text
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
    doc.at("./relation[@type = 'includedIn']") and return "inbook"
    "book"
  end

  def extent1(localities)
    localities.each_with_object({}) do |l, ret|
      ret[(l["type"] || "page").to_sym] = {
        from: l.at("./referenceFrom")&.text,
        to: l.at("./referenceTo")&.text,
      }
    end
  end

  def extent0(elem, acc, ret1)
    case elem.name
    when "localityStack"
      acc << ret1
      ret1 = {}
      acc << extent1(elem.elements)
    when "locality" then ret1.merge!(extent1([elem]))
    when "referenceFrom" then ret1.merge!(extent1([elem.parent]))
    end
    [acc, ret1]
  end

  def extent(doc)
    ret1 = {}
    ret = doc.xpath("./extent").each_with_object([]) do |e, acc|
      e.elements.each do |l|
        acc, ret1 = extent0(l, acc, ret1)
        break if l.name == "referenceFrom"
      end
    end
    ret << ret1
    ret.reject(&:empty?)
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
