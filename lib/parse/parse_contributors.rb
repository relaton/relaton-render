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

  def date1(date)
    on = date.at("./on")
    from = date.at("./from")
    to = date.at("./to")
    return { on: on.text } if on
    return { from: from.text, to: to&.text } if from

    nil
  end

  def date(doc, host)
    x = doc.at("./date[@type = 'issued']") ||
      doc.at("./date[@type = 'circulated']") ||
      doc.at("./date") ||
      host&.at("./date[@type = 'issued']") ||
      host&.at("./date[@type = 'circulated']") ||
      host&.at("./date") or return nil
    date1(x)
  end

  def date_updated(doc, host)
    x = doc.at("./date[@type = 'updated']") ||
      host&.at("./date[@type = 'updated']") or return nil
    date1(x)
  end

  def date_accessed(doc, host)
    x = doc.at("./date[@type = 'accessed']") ||
      host&.at("./date[@type = 'accessed']") or return nil
    date1(x)
  end
end
