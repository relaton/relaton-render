class Iso690Render
  def date1(date)
    return nil if date.nil?

    on = date&.at("./on")&.text
    from = date&.at("./from")&.text
    to = date&.at("./to")&.text
    return MMMddyyyy(on) if on
    return "#{MMMddyyyy(from)}&ndash;#{MMMddyyyy(to)}" if from

    nil
  end

  def date(doc)
    pub = date1(doc&.at("./date[@type = 'issued']")) and return pub
    pub = date1(doc&.at("./date[@type = 'circulated']")) and return pub
    date1(doc&.at("./date"))
  end

  def date_updated(doc)
    date1(doc&.at("./date[@type = 'updated']"))
  end

  def year(date)
    return nil if date.nil?

    date.sub(/^(\d\d\d\d).*$/, "\\1")
  end

  def MMMddyyyy(isodate)
    return nil if isodate.nil?
    return isodate if isodate == "--"

    arr = isodate.split("-")
    if arr.size == 1 && (/^\d+$/.match isodate)
      Date.new(*arr.map(&:to_i)).strftime("%Y")
    elsif arr.size == 2
      Date.new(*arr.map(&:to_i)).strftime("%B %Y")
    else
      Date.parse(isodate).strftime("%B %d, %Y")
    end
  end
end
