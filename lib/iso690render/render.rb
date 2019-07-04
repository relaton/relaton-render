require "nokogiri"

module Iso690Render
=begin
  Out of scope: Provenance (differentiating elements by @source in rendering)
=end

  def self.render(bib)
    docxml = Nokogiri::XML(bib)
    parse(docxml.root)
  end

  def self.multiplenames(names)
    return "" if names.length == 0
    return names[0] if names.length == 1
    return "#{names[0]} and #{names[1]}" if names.length == 2
    names[0..-2].join(", ") + " and #{names[-1]}"
  end

  def self.extract_orgname(org)
    name = org.at("./name")
    name&.text || "--"
  end

  def self.frontname(initials, given)
    if given.empty? && initials.empty? then ""
    elsif initials.empty?
      given.map{ |m| m.text }.join(" ")
    else
      initials.map{ |m| m.text }.join(" ")
    end
  end

  def self.commajoin(a, b)
    return a unless b
    return b unless a
    "#{a}, #{b}"
  end

  def self.extract_personname(person)
    completename = person.at("./completename")
    return completename.text if completename
    surname = person.at("./name/surname")
    initials = person.xpath("./name/initials")
    forenames = person.xpath("./name/forename")
    #given = []
    #forenames.each { |x| given << x.text }
    #given.empty? && initials.each { |x| given << x.text }
    commajoin(surname&.text&.upcase, frontname(forenames, initials))
  end

  def self.extractname(contributor)
    org = contributor.at("./organization")
    person = contributor.at("./person")
    return extract_orgname(org) if org
    return extract_personname(person) if person
    "--"
  end

  def self.contributorRole(contributors)
    return "" unless contributors.length > 0
    if contributors[0]["role"] == "editor"
      return contributors.length > 1 ? " (Eds.)" : "(Ed.)"
    end
    ""
  end

  def self.creatornames(doc)
    cr = doc.xpath("/bibitem/contributor[role/@type = 'author']") 
    cr.empty? and cr = doc.xpath("/bibitem/contributor[role/@type = 'performer']") 
    cr.empty? and cr = doc.xpath("/bibitem/contributor[role/@type = 'adapter']") 
    cr.empty? and cr = doc.xpath("/bibitem/contributor[role/@type = 'translator']") 
    cr.empty? and cr = doc.xpath("/bibitem/contributor[role/@type = 'editor']") 
    cr.empty? and cr = doc.xpath("/bibitem/contributor[role/@type = 'publisher']") 
    cr.empty? and cr = doc.xpath("/bibitem/contributor[role/@type = 'distributor']") 
    cr.empty? and cr = doc.xpath("/bibitem/contributor")
    cr.empty? and return ""
    ret = []
    cr.each do |x|
      ret << extractname(x)
    end
    multiplenames(ret) + contributorRole(cr)
  end

  def self.title(doc)
    doc&.at("./bibitem/title")&.text
  end

  def self.medium(doc)
    doc&.at("./bibitem/medium")&.text
  end

  def self.edition(doc)
    x = doc.at("./bibitem/edition")
    return "" unless x
    return x.text unless /^\d+$/.match x
    x.to_i.localize.to_rbnf_s("SpelloutRules", "spellout-ordinal")
  end

  def self.placepub(doc)
    place = doc.at("./bibitem/place")
    publisher = doc.at("/bibitem/contributor[role = 'publisher']/organization/name")
    ret = ""
    ret += place.text if place
    ret += ": " if place && publisher
    ret += publisher.text if publisher
    ret
  end

  def self.date1(date)
    return nil if date.nil?
    on = date&.at("./on")&.text
    return on if on
    from = date&.at("./from")&.text
    to = date&.at("./to")&.text
    return "#{from}&ndash;#{to}" if from
    nil
  end

  def self.date(doc)
    pub = date1(doc&.at("./bibitem/date[@type = 'published']")) and return pub
    date1(doc&.at("./bibitem/date"))
  end

  def self.series(doc, type)
    s = doc.at("./bibitem/series[@type = 'main']") || 
      doc.at("./bibitem/series[not(@type)]") ||
      doc.at("./bibitem/series")
    return "" unless s
    f = s.at("./formattedref") and return r.text
    t = s.at("./title")
    n = s.at("./number")
    p = s.at("./partnumber")
    ret = ""
    if t
      title = included(type) ? wrap(t.text, " <I>", "</I>.") : wrap(t.text)
      ret += title
    end
    ret += " #{n.text}" if n
    ret += ".#{p.text}" if p
    ret
  end

  def self.standardidentifier(doc)
    ret = []
    doc.xpath("./bibitem/docidentifier").each do |id|
      r = ""
      r += "#{id['type']} " if id["type"]
      r += id.text
      ret << r
    end
    ret.join(". ")
  end

  def self.accessLocation(doc)
    s = doc.at("./bibitem/accessLocation") or return ""
    s.text
  end

  def self.included(type)
    ["article", "inbook", "incollection", "inproceedings"].include? type
  end

  def self.wrap(text, startdelim = " ", enddelim = ".")
    return "" if text.nil? || text.empty?
    "#{startdelim}#{text}#{enddelim}"
  end

  def self.type(doc)
    type = doc.at("./bibitem/@type") and return type&.text
    doc.at("./bibitem/includedIn") and return "inbook"
    "book"
  end

  def self.extent1(type, from, to)
    ret = ""
    if type == "page"
      type = to ? "pp." : "p"
    end
    ret += "#{type} "
    ret += from.text if from
    ret += "&ndash;#{to.text}" if to
    ret
  end

  def self.extent(localities)
    ret = []
    localities.each do |l|
      ret << extent1(l["type"] || "page", 
                     l.at("./referenceFrom"), l.at("./referenceTo"))
    end
    ret.join(", ")
  end

  def self.parse(xml, embedded = false)
    ret = ""
    doc = Nokogiri::XML(xml)
    type = type(doc)
    container = doc.at("./bibitem/relation[@type='includedIn']")
    if container && date(doc) && !date(container)
      container.at("./bibitem") << doc.at("./bibitem/date[@type = 'published']").remove
    end
    ret += embedded ? wrap(creatornames(doc), " ", ",") : wrap(creatornames(doc), "", ".")
    ret += included(type) ? wrap(title(doc)) : wrap(title(doc), " <I>", "</I>.")
    ret += wrap(medium(doc), " [", "].")
    ret += wrap(edition(doc))
    ret += date(doc) ? wrap(placepub(doc), " ", ",") : wrap(placepub(doc))
    ret += wrap(date(doc))
    ret += wrap(series(doc, type))
    ret += wrap(standardidentifier(doc))
    ret += wrap(accessLocation(doc), "At: ", ".")
    if container 
      ret += wrap(parse(container.at("./bibitem").to_xml, true), " In:", "")
      locality = container.xpath("./locality")
      locality.empty? and locality = doc.xpath("./bibitem/extent")
      ret += wrap(extent(locality))
    else
      ret += wrap(extent(doc.xpath("./bibitem/extent")))
    end
    embedded ? ret : "<p>#{ret}</p>"
  end
end
