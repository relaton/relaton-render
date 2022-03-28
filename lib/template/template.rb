class Iso690Template
  def initialize(opt = {})
    opt = sym_keys(opt)
    @i18n = opt[:i18n]
    @template =
      case opt[:template]
      when Hash
        opt[:template].transform_values { |x| Liquid::Template.parse(x) }
      when Array
        opt[:template].map { |x| Liquid::Template.parse(x) }
      else { default: Liquid::Template.parse(opt[:template]) }
      end
  end

  def sym_keys(hash)
    case hash
    when Hash
      hash.each_with_object({}) { |(k, v), ret| ret[k.to_sym] = sym_keys(v) }
    when Array then hash.map { |n| sym_keys(n) }
    else hash
    end
  end

  def render(hash)
    template_clean(template_select(hash)
      .render(liquid_hash(hash.merge("labels" => @i18n.get))))
  end

  def template_select(_hash)
    @template[:default]
  end

  # use tab internally for non-spacing delimiter
  def template_clean(str)
    str = str.gsub(/\S*#{EMPTYFIELD}\S*/o, "")
      .gsub(/_/, " ").gsub(/[\t\n]/, " ")
      .gsub(/([,.:]\s*)+([,.]\s)/, "\\2")
      .gsub(/(:\s+)(&\s)/, "\\2")
      .gsub(/\s+([,.:])/, "\\1")
      .gsub(/\t/, "").gsub(/\s+/, " ")
    str.strip
  end

  # \u0018 signals empty field
  EMPTYFIELD = "\u0018".freeze

  def liquid_hash(hash)
    hash.map { |k, v| [k.to_s, empty2nil(v)] }.to_h
  end

  def empty2nil(str)
    return EMPTYFIELD if str.nil? || (str.is_a?(String) && str.empty?)
    return [EMPTYFIELD] if str.is_a?(Array) && str.empty?

    str
  end
end

class Iso690SeriesTemplate < Iso690Template
end

class Iso690NameTemplate < Iso690Template
  def initialize(opt = {})
    @etal_count = opt[:template]["etal_count"]
    @nametemplate_more = opt[:template]["more"]
    opt[:template].delete("etal_count")
    super
  end

  def template_select(names)
    case names[:surname].size
    when 1 then @template[:one]
    when 2 then @template[:two]
    when 3 then @template[:more]
    else
      if @etal_count && names.size >= @etal_count
        @template[:etal]
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
    if match = /^\{\{.+?\[(\d)\]/.match(elem)
      curr += 1 if match[0].to_i > curr
      acc[curr] += prec
      prec = ""
      acc[curr] += elem
    else prec += elem
    end
    [acc, curr, prec]
  end
end
