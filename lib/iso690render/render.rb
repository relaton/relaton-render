require_relative "render_classes"
require "yaml"
require "liquid"
require_relative "i18n"

class Iso690Render
  attr_reader :template

  def initialize(opt = {})
    options = YAML.load_file(File.join(File.dirname(__FILE__), "config.yml"))
      .merge(string_keys(opt))
    root_initalize(options) if instance_of?(Iso690Render) # root only
    @parse ||= options["parse"]
    @i18n ||= options["i18n"]
    options["template"].is_a? String and
      @template = Iso690Template.new(template: options["template"])
  end

  def root_initalize(opt)
    @i18n = i18n(opt["language"], opt["script"])
    @parse = Iso690Parse.new
    @nametemplate = Iso690NameTemplate.new(template: opt["nametemplate"])
    @seriestemplate = Iso690SeriesTemplate.new(template: opt["seriestemplate"])
    @render = renderers(opt)
  end

  def renderers(opt)
    Iso690Render::BIBTYPE.each_with_object({}) do |type, m|
      template = opt["template"][type] || opt["template"]["misc"] ||
        default_template
      m[type] = Iso690Render.subclass(type)
        .new(template: template, parse: @parse, i18n: @i18n)
    end
  end

  def default_template
    "{{creatornames}}. {{title}}. {{date}}."
  end

  def string_keys(hash)
    case hash
    when Hash
      hash.each_with_object({}) { |(k, v), ret| ret[k.to_s] = string_keys(v) }
    when Array then hash.map { |n| string_keys(n) }
    else hash
    end
  end

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
    r = @render[doc["type"]]
    data = @parse.extract(doc).merge("labels" => @i18n.get)
    data_liquid = compound_fields_format(data)
    @i18n.l10n(r.template.render(data_liquid))
  end

  def compound_fields_format(hash)
    hash[:creatornames] = nameformat(hash[:creators])
    hash[:role] = role_inflect(hash[:creators], hash[:role_raw])
    hash[:host_creatornames] = nameformat(hash[:host_creators])
    hash[:host_role] = role_inflect(hash[:host_creators], hash[:host_role_raw])
    hash[:series] = seriesformat(hash)
    hash
  end

  def seriesformat(hash)
    parts = %i(series_title series_abbr series_num series_partnumber)
    series_out = parts.each_with_object({}) do |i, m|
      m[i] = hash[i]
    end
    @seriestemplate.render(series_out)
  end

  def nameformat(names)
    parts = %i(surname initials given middle)
    names_out = names.each_with_object({}) do |n, m|
      parts.each do |i|
        m[i] ||= []
        m[i] << n[i]
      end
    end
    @nametemplate.render(names_out)
  end

  def role_inflect(contribs, role)
    return nil if role.nil? || contribs.size.zero?

    number = contribs.size > 1 ? "pl" : "sg"
    @i18n.get[role][number] || role
  end
end
