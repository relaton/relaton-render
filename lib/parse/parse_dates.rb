class Iso690Parse
  def date1(date)
    on = date.at("./on")
    from = date.at("./from")
    to = date.at("./to")
    return MMMddyyyy(on.text) if on
    return "#{MMMddyyyy(from.text)}&ndash;#{MMMddyyyy(to.text)}" if from

    nil
  end

  def date(doc, host)
    x = doc.at("./date[@type = 'issued']") ||
      doc.at("./date[@type = 'circulated']") ||
      doc.at("./date") ||
      host.at("./date[@type = 'issued']") ||
      host.at("./date[@type = 'circulated']") ||
      host.at("./date") or return nil
    date1(x)
  end

  def date_updated(doc, host)
    x = doc.at("./date[@type = 'updated']") ||
      host.at("./date[@type = 'updated']") or return nil
    date1(x)
  end

  def date_accessed(doc, host)
    x = doc.at("./date[@type = 'accessed']") ||
      host.at("./date[@type = 'accessed']") or return nil
    date1(x)
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
