class Iso690Render
  #   def self.multiplenames_and(names)
  #     return "" if names.length == 0
  #     return names[0] if names.length == 1
  #     return "#{names[0]} and #{names[1]}" if names.length == 2
  #     names[0..-2].join(", ") + " and #{names[-1]}"
  #   end

  def multiplenames(names)
    names.join(", ")
  end

  def extract_orgname(org)
    name = org.at("./name")
    name&.text || "--"
  end

  def frontname(given, initials)
    if given.empty? && initials.empty? then ""
    elsif initials.empty?
      given.map { |m| m.text[0] }.join
    else
      initials.map { |m| m.text[0] }.join
    end
  end

  def commajoin(elem1, elem2)
    return elem1 unless elem2
    return elem2 unless elem1

    "#{elem1} #{elem2}"
  end

  def extract_personname(person)
    completename = person.at("./name/completename")
    return completename.text if completename

    surname = person.at("./name/surname")
    initials = person.xpath("./name/initial")
    forenames = person.xpath("./name/forename")
    # given = []
    # forenames.each { |x| given << x.text }
    # given.empty? && initials.each { |x| given << x.text }
    commajoin(surname&.text, frontname(forenames, initials))
  end

  def extractname(contributor)
    org = contributor.at("./organization")
    person = contributor.at("./person")
    return extract_orgname(org) if org
    return extract_personname(person) if person

    "--"
  end

  def contributor_role(contributors)
    return "" unless contributors.length.positive?
    if contributors[0]&.at("role/@type")&.text == "editor"
      return contributors.length > 1 ? " (Eds.)" : "(Ed.)"
    end

    ""
  end

  def creatornames(doc)
    cr = doc.xpath("./contributor[role/@type = 'author']")
    cr.empty? and cr = doc.xpath("./contributor[role/@type = 'performer']")
    cr.empty? and cr = doc.xpath("./contributor[role/@type = 'adapter']")
    cr.empty? and cr = doc.xpath("./contributor[role/@type = 'translator']")
    cr.empty? and cr = doc.xpath("./contributor[role/@type = 'editor']")
    cr.empty? and cr = doc.xpath("./contributor[role/@type = 'publisher']")
    cr.empty? and cr = doc.xpath("./contributor[role/@type = 'distributor']")
    cr.empty? and cr = doc.xpath("./contributor")
    cr.empty? and return ""
    ret = []
    cr.each do |x|
      ret << extractname(x)
    end
    multiplenames(ret) + contributor_role(cr)
  end
end
