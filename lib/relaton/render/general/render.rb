require_relative "render_classes"
require_relative "citations"
require "yaml"
require "liquid"
require "relaton_bib"
require_relative "../template/template"
require_relative "../../../isodoc/i18n"

module Relaton
  module Render
    class General
      attr_reader :template, :journaltemplate, :seriestemplate, :nametemplate,
                  :authorcitetemplate, :extenttemplate, :sizetemplate,
                  :lang, :script, :i18n,
                  :edition, :edition_ordinal, :date

      def initialize(opt = {})
        options = read_config.merge(Utils::string_keys(opt))
        @type = self.class.name.downcase.split("::").last
        klass_initialize(options)
        root_initalize(options)
        render_initialize(options)
        @parse ||= options["parse"]
      end

      def read_config
        YAML.load_file(File.join(File.dirname(__FILE__), "config.yml"))
      end

      def klass_initialize(_options)
        @nametemplateklass = Relaton::Render::Template::Name
        @authorcitetemplateklass = Relaton::Render::Template::AuthorCite
        @seriestemplateklass = Relaton::Render::Template::Series
        @extenttemplateklass = Relaton::Render::Template::Extent
        @sizetemplateklass = Relaton::Render::Template::Size
        @generaltemplateklass = Relaton::Render::Template::General
        @fieldsklass = Relaton::Render::Fields
        @parseklass = Relaton::Render::Parse
      end

      def root_initalize(opt)
        i18n_initialize(opt)
        @parse = @parseklass.new(lang: @lang, script: @script)
        @nametemplate = @nametemplateklass
          .new(template: opt["nametemplate"], i18n: @i18n)
        @authorcitetemplate = @authorcitetemplateklass
          .new(template: opt["authorcitetemplate"], i18n: @i18n)
        @seriestemplate = @seriestemplateklass
          .new(template: opt["seriestemplate"], i18n: @i18n)
        @journaltemplate = @seriestemplateklass
          .new(template: opt["journaltemplate"], i18n: @i18n)
        @extenttemplate = extentrenderers(opt)
        @sizetemplate = sizerenderers(opt)
      end

      def i18n_initialize(opt)
        @lang = opt["language"]
        @script = opt["script"]
        @i18n = opt["i18n"] ||
          i18n_klass(opt["language"], opt["script"], opt["i18nhash"])
        @edition_ordinal = opt["edition_ordinal"] || @i18n.edition_ordinal
        @edition = opt["edition"] || @i18n.edition
        @date = opt["date"] || @i18n.get["date_formats"] ||
          { "month_year" => "yMMMM",
            "day_month_year" => "to_long_s",
            "date_time" => "to_long_s" }
      end

      def render_initialize(opt)
        case opt["template"]
        when String
          @template = @generaltemplateklass
            .new(template: opt["template"], i18n: @i18n)
        when Hash
          @render = renderers(opt)
        end
      end

      def renderers(opt)
        template_hash_fill(opt["template"]).each_with_object({}) do |(k, v), m|
          @type == "general" || @type == k or next
          m[k] = General.subclass(k)
            .new(template: v, parse: @parse, i18n: @i18n,
                 language: @lang, script: @script)
        end
      end

      def extentrenderers(opt)
        @extenttemplateklass
          .new(template: template_hash_fill(opt["extenttemplate"]), i18n: @i18n)
      end

      def sizerenderers(opt)
        @sizetemplateklass
          .new(template: template_hash_fill(opt["sizetemplate"]), i18n: @i18n)
      end

      def default_template
        "{{creatornames}}. {{title}}. {{date}}."
      end

      def i18n_klass(lang = "en", script = "Latn", i18nhash = nil)
        ::IsoDoc::RelatonRenderI18n.new(lang, script, i18nhash: i18nhash)
      end

      def render(bib, embedded: false)
        if bib.is_a?(String) && Nokogiri::XML(bib).errors.empty?
          bib = RelatonBib::XMLParser.from_xml bib
        end
        parse(bib, embedded: embedded)
      end

      def parse(doc, embedded: false)
        f = doc.formattedref and
          return embedded ? f.children.to_xml : doc.to_xml

        ret = parse1(doc) or return nil
        embedded and return ret
        "<formattedref>#{ret}</formattedref>"
      end

      def renderer(type)
        ret = @template || @render[type]&.template or
          raise "No renderer defined for #{type}"
        @type == "general" || @type == type or
          raise "No renderer defined for #{type}"

        ret
      end

      def parse1(doc)
        r = renderer(doc.type || "misc")
        data = @parse.extract(doc)
        data_liquid = @fieldsklass.new(renderer: self)
          .compound_fields_format(data)
        @i18n.l10n(r.render(data_liquid))
      end

      # expect array of Relaton objects, in sorted order
      def render_all(bib, type: "author-date")
        bib = sanitise_citations_input(bib) or return
        Citations.new(type: type, renderer: self, i18n: @i18n)
          .render(citations1(bib))
      end

      def sanitise_citations_input(bib)
        bib.is_a?(Array) and return bib
        bib.is_a?(String) and return sanitise_citations_input_string(bib)
      end

      def sanitise_citations_input_string(bib)
        p = Nokogiri::XML(bib) or return
        (p.errors.empty? && p.root.at("./bibitem")) or return nil

        p.root.xpath("./bibitem").each_with_object([]) do |b, m|
          m << RelatonBib::XMLParser.from_xml(b.to_xml)
        end
      end

      def citations1(bib)
        bib.each_with_object([]).with_index do |(b, m), i|
          data_liquid = @fieldsklass.new(renderer: self)
            .compound_fields_format(@parse.extract(b))
          m << { author: data_liquid[:authorcite], date: data_liquid[:date],
                 ord: i, id: b.id, data_liquid: data_liquid, type: b.type }
        end
      end

      private

      def template_hash_fill(templates)
        BIBTYPE.each_with_object({}) do |type, m|
          template = templates[type] || templates["misc"] || default_template
          BIBTYPE.include?(template) and template = templates[template]
          m[type] = template
        end
      end
    end
  end
end
