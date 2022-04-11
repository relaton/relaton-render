require_relative "render_classes"
require "yaml"
require "liquid"
require "relaton_bib"
require_relative "../template/template"

module Relaton
  module Render
    class General
      attr_reader :template, :journaltemplate, :seriestemplate, :nametemplate,
                  :extenttemplate, :sizetemplate, :lang, :script, :i18n,
                  :edition, :edition_number, :date

      def initialize(opt = {})
        options = YAML.load_file(File.join(File.dirname(__FILE__),
                                           "config.yml"))
          .merge(Utils::string_keys(opt))
        @type = self.class.name.downcase.sub(/relaton::render::/, "")
        root_initalize(options)
        render_initialize(options)
        @parse ||= options["parse"]
        @i18n ||= options["i18n"]
      end

      def root_initalize(opt)
        i18n_initialize(opt)
        @parse = Parse.new
        @nametemplate = Relaton::Render::Template::Name
          .new(template: opt["nametemplate"], i18n: @i18n)
        @seriestemplate = Relaton::Render::Template::Series
          .new(template: opt["seriestemplate"], i18n: @i18n)
        @journaltemplate = Relaton::Render::Template::Series
          .new(template: opt["journaltemplate"], i18n: @i18n)
        @extenttemplate = extentrenderers(opt)
        @sizetemplate = sizerenderers(opt)
      end

      def i18n_initialize(opt)
        @lang = opt["language"]
        @script = opt["script"]
        @i18n = i18n_klass(opt["language"], opt["script"])
        @edition_number = opt["edition_number"] || @i18n.edition_number
        @edition = opt["edition"] || @i18n.edition
        @date = opt["date"] || @i18n.date
      end

      def render_initialize(opt)
        case opt["template"]
        when String
          @template = Relaton::Render::Template::General
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
        Relaton::Render::Template::Extent
          .new(template: template_hash_fill(opt["extenttemplate"]), i18n: @i18n)
      end

      def sizerenderers(opt)
        Relaton::Render::Template::Size
          .new(template: template_hash_fill(opt["sizetemplate"]), i18n: @i18n)
      end

      def default_template
        "{{creatornames}}. {{title}}. {{date}}."
      end

      def i18n_klass(lang = "en", script = "Latn")
        ::IsoDoc::RelatonRenderI18n.new(lang, script)
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

        ret = parse1(doc)
        embedded and return ret
        "<formattedref>#{ret}</formattedref>"
      end

      def renderer(doc)
        unless ret = @template || @render[doc.type]&.template
          raise "No renderer defined for #{doc.type}"
        end
        unless @type == "general" || @type == doc.type
          raise "No renderer defined for #{doc.type}"
        end

        ret
      end

      def parse1(doc)
        r = renderer(doc)
        data = @parse.extract(doc)
        data_liquid = Fields.new(renderer: self).compound_fields_format(data)
        @i18n.l10n(r.render(data_liquid))
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
