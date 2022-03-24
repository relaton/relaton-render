require_relative "render_classes"
require_relative "parse"
require "liquid"
require "isodoc-i18n"

class Iso690Render
  attr_reader :template

  def initialize(opt)
    root_initalize(opt) if instance_of?(Iso690Render) # root only
    @parse ||= opt[:parse]
    @i18n ||= opt[:i18n]
    opt[:template].is_a? String and
      @template = Liquid::Template.parse(opt[:template])
  end

  def root_initalize(opt)
    @i18n = i18n(opt[:language], opt[:script])
    @parse = Iso690Parse.new
    @nametemplate_more = opt[:nametemplate][:more]
    @nametemplate = opt[:nametemplate].transform_values do |x|
      Liquid::Template.parse(x)
    end
    @render = Iso690Render::BIBTYPE.each_with_object({}) do |t, m|
      m[t] = renderer(opt, t)
    end
  end

  def renderer(opt, type)
    template = opt[:template][type] || opt[:template][:misc] ||
      DEFAULT_TEMPLATE
    Iso690Render.subclass(type)
      .new(template: template, parse: @parse, i18n: @i18n)
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
    data = liquid_hash(nameformat(@parse.extract(doc).merge(@i18n.get)))
    template_clean(r.template.render(data))
  end

  def nameformat(hash)
    hash[:creatornames] = nameformat1(hash[:creators])
    hash[:host_creatornames] = nameformat1(hash[:host_creators])
    hash
  end

  def liquid_hash(hash)
    hash.map { |k, v| [k.to_s, empty2nil(v)] }.to_h
  end

  def nameformat1(names)
    t = nametemplate(names)
    parts = %i(surname initials given middle)
    names_out = names.each_with_object({}) do |n, m|
      parts.each do |i|
        m[i] ||= []
        m[i] << n[i]
      end
    end
    t.render(liquid_hash(names_out))
  end

  def nametemplate(names)
    case names.size
    when 1 then @nametemplate[:one]
    when 2 then @nametemplate[:two]
    when 3 then @nametemplate[:more]
    else
      if @nametemplate[:etal_count] && names.size >= @nametemplate[:etal_count]
        @nametemplate[:etal]
      else expand_nametemplate(@nametemplate_more, names.size)
      end
    end
  end

  # assumes that template contains, consecutively and not interleaved,
  # ...[0], ...[1], ...[2]
  def expand_nametemplate(template, size)
    t = nametemplate_split(template)
    mid = (1..size - 2).each_with_object([]) do |i, m|
      m << t[1].gsub(/\[1\]/, "[#{i}]")
    end
    Liquid::Template
      .parse(t[0] + mid.join + t[2].gsub(/\[2\]/, "[#{size - 1}]"))
  end

  def nametemplate_split(template)
    curr = 0
    prec = ""
    t = template.split(/(\{\{.+?\}\})/)
      .each_with_object(["", "", ""]) do |n, m|
      m, curr, prec = nametemplate_split1(n, m, curr, prec)
      m
    end
    t[-1] += prec
    t
  end

  def nametemplate_split1(elem, acc, curr, prec)
    if match = /^\{\{.+?\[(\d)\]/.match?(elem)
      curr += 1 if match[0].to_i > curr
      acc[curr] += prec
      prec = ""
      acc[curr] += elem
    else prec += elem
    end
    [acc, curr, prec]
  end

  # \u0018 signals empty field
  EMPTYFIELD = "\u0018".freeze

  def empty2nil(str)
    return EMPTYFIELD if str.nil? || (str.is_a?(String) && str.empty?)
    return [EMPTYFIELD] if str.is_a?(Array) && str.empty?

    str
  end

  def template_clean(str)
    str.gsub(/\S*#{EMPTYFIELD}\S*/o, "").gsub(/_/, " ").strip.sub(/^\s*\|./, "")
      .gsub(/(\|\S\s*)+(\|\S)/, "\\2").gsub(/\s*\|/, "")
  end

  def contributor_role(contributors)
    return "" unless contributors.length.positive?
    if contributors[0]&.at("role/@type")&.text == "editor"
      return contributors.length > 1 ? " (Eds.)" : "(Ed.)"
    end

    ""
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
