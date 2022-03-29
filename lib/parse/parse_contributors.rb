class Iso690Parse
  def extract_orgname(org)
    name = org.at("./name")
    name&.text
  end

  def extract_personname(person)
    surname = person.at("./name/surname") || person.at("./name/completename")
    given, middle, initials = given_and_middle_name(person)
    { surname: surname&.text,
      given: given,
      middle: middle,
      initials: initials }
  end

  def given_and_middle_name(person)
    forenames = person.xpath("./name/forename")&.map(&:text)
    initials = person.xpath("./name/initial")&.map(&:text)
    forenames.empty? and initials.empty? and return [nil, nil, nil]
    forenames.empty? and forenames = initials.dup
    initials.empty? and initials = forenames.map { |x| x[0] }
    [forenames.first, forenames[1..-1], initials]
  end

  def extractname(contributor)
    org = contributor.at("./organization")
    person = contributor.at("./person")
    return { surname: extract_orgname(org) } if org
    return extract_personname(person) if person

    nil
  end

  def contributor_role(contributors)
    return nil unless contributors.length.positive?

    desc = contributors[0].at("role/description")&.text
    type = contributors[0].at("role/@type")&.text
    return nil if %w(author publisher).include?(type) && desc.nil?

    type
  end

  def creatornames(doc)
    cr = creatornames1(doc)
    cr.empty? and return [nil, nil]
    [cr.map { |x| extractname(x) }, contributor_role(cr)]
  end

  def creatornames1(doc)
    cr = []
    return cr if doc.nil?

    %w(author performer adapter translator editor publisher distributor)
      .each do |r|
        add = doc.xpath("./contributor[role/@type = '#{r}']")
        next if add.empty?

        cr = add and break
      end
    cr.empty? and cr = doc.xpath("./contributor")
    cr
  end
end
