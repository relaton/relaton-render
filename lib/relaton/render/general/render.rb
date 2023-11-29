require_relative "render_classes"
require_relative "citations"
require "yaml"
require "liquid"
require "date"
require "relaton_bib"
require "net/http"
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
        @parse = @parseklass.new(lang: @lang, script: @script, i18n: @i18n)
        @nametemplate = @nametemplateklass
          .new(template: opt["nametemplate"], i18n: @i18n)
        @authorcitetemplate = @authorcitetemplateklass
          &.new(template: opt["authorcitetemplate"], i18n: @i18n)
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
        @locale = opt["locale"]
        @i18n = opt["i18n"] ||
          i18n_klass(language: @lang, script: @script, locale: @locale,
                     i18nhash: opt["i18nhash"])
        @edition_ordinal = opt["edition_ordinal"] || @i18n.edition_ordinal
        @edition = opt["edition"] || @i18n.edition
        @date = opt["date"] || @i18n.get["date_formats"] ||
          { "month_year" => "yMMMM", "day_month_year" => "to_long_s",
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

      def i18n_klass(language: "en", script: "Latn", locale: nil, i18nhash: nil)
        ::IsoDoc::RelatonRenderI18n.new(language, script, locale: locale,
                                                          i18nhash: i18nhash)
      end

      def render(bib, embedded: false)
        if bib.is_a?(String) && Nokogiri::XML(bib).errors.empty?
          bib = RelatonBib::XMLParser.from_xml bib
        end
        parse(bib, embedded: embedded)
      end

      def fmtref(doc)
        "<formattedref>#{doc}</formattedref>"
      end

      def parse(doc, embedded: false)
        f = doc.formattedref and
          return embedded ? f.content : fmtref(f.content)
        ret = parse1(doc) or return nil
        embedded and return ret
        fmtref(ret)
      end

      def renderer(type)
        ret = @template || @render[type]&.template or
          raise "No renderer defined for #{type}"
        @type == "general" || @type == type or
          raise "No renderer defined for #{type}"

        ret
      end

      def parse1(doc)
        r = doc.relation.select { |x| x.type == "hasRepresentation" }
          .map { |x| @i18n.also_pub_as + parse_single_bibitem(x.bibitem) }
        out = [parse_single_bibitem(doc)] + r
        @i18n.l10n(out.join(". ").gsub(".. ", ". "))
      end

      def parse_single_bibitem(doc)
        r = renderer(doc.type || "misc")
        data = @parse.extract(doc)
        enhance_data(data, r.template_raw)
        data_liquid = @fieldsklass.new(renderer: self)
          .compound_fields_format(data)
        valid_parse(@i18n.l10n(r.render(data_liquid)))
      end

      def valid_parse(ret)
        @i18n.get["no_date"] == ret and return nil
        ret
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

      # add to liquid data based on template
      def enhance_data(data, template)
        template.is_a?(String) or return
        add_date_accessed(data, template)
      end

      def add_date_accessed(data, template)
        (/\{\{\s*date_accessed\s*\}\}/.match?(template) &&
          /\{\{\s*uri\s*\}\}/.match?(template) &&
          data[:uri_raw] && !data[:date_accessed]) or return
        if url_exist?(data[:uri_raw])
          data[:date_accessed] = { on: ::Date.today.to_s }
        else
          warn "BIBLIOGRAPHY WARNING: cannot access #{data[:uri_raw]}"
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

      def url_exist?(url_string)
        res = access_url(url_string)
        res.is_a?(Net::HTTPRedirection) and return url_exist?(res["location"])
        res.code[0] != "4"
      rescue Errno::ENOENT, SocketError
        false # false if can't find the server
      end

      def access_url(url_string)
        url = URI.parse(url_string)
        req = Net::HTTP.new(url.host, url.port)
        req.use_ssl = (url.scheme == "https")
        path = url.path or return false
        path.empty? and path = "/"
        req.request_head(path)
      end
    end
  end
end
