require "nokogiri"

module Iso690Render
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

  def self.extract_personname(person)
    completename = person.at("./completename")
    return completename.text if completename
    surname = person.at("./surname")
    initials = person.xpath("./initial")
    forenames = person.xpath("./forename")
    given = []
    forenames.each { |x| given << x.text }
    given.empty? && initials.each { |x| given << x.text }
    front = if forenames.empty? && initials.empty? 
              ""
            elsif initials.empty? 
              given.join(" ")
            else 
              given "" 
            end
    "#{surname.upcase}, #{front}"
  end

  def self.extractname(contributor)
    org = contributor.at("./organization")
    person = contributor.at("./person")
    return extract_orgname(org) if org
    return extract_personname(person) if person
    "--"
  end

  def self.creatornames(doc)
    cr = doc.xpath("/bibitem/contributor[role = 'author']") ||
      doc.xpath("/bibitem/contributor[role = 'performer']") ||
      doc.xpath("/bibitem/contributor[role = 'publisher']") ||
      doc.xpath("/bibitem/contributor[role = 'adapter']") ||
      doc.xpath("/bibitem/contributor[role = 'translator']") ||
      doc.xpath("/bibitem/contributor[role = 'distributor']")
    ret = []
    cr.each do |x|
      ret << extractname(x)
    end
    multiplenames(ret)
  end

  def self.title(doc)
    doc.at("./bibitem/title")
  end

  def self.medium(doc)
    doc.at("./bibitem/medium")
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

  def self.date(doc)
    doc.at("./bibitem/date[@type = 'published']")
  end

  def self.series(doc)
    s = doc.at("./bibitem/series[@type = 'main']") || 
      doc.at("./bibitem/series[not(@type)]") ||
      doc.at("./bibitem/series")
    return "" unless s
    f = s.at("./formattedref") and return r.text
    t = s.at("./title")
    n = s.at("./number")
    p = s.at("./partnumber")
    ret = ""
    ret += t.text if t
    ret += " #{n.text}" if n
    ret += ".#{p.text}" if p
    p
  end

  def self.wrap(text, startdelim = " ", enddelim = ".")
    return "" if text.nil? || text.empty?
    "#{startdelim}#{text}#{enddelim}"
  end

  # series title; numeration within item; standard identifier; availability accesss or location; additional general information
  def self.parse(doc)
    ret = ""
    ret += wrap(creatornames(doc))
    ret += wrap(title(doc), " <I>", "</I>.")
    ret += wrap(medium(doc), " [", "].")
    ret += wrap(edition(doc))
    ret += wrap(placepub(doc))
    ret += wrap(date(doc))
    ret += wrap(series(doc))
    ret
  end

=begin
  def self.parse(node)
    out = ""
    if node.text?
      return node.text
    else
      case node.name
      when "bib"
        node.elements.each { |n| out << parse(n) }
        return out
      else
        node.to_xml
      end
    end
    end
=end
end
