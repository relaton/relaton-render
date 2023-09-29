require "yaml"
require "isodoc-i18n"

module IsoDoc
  class RelatonRenderI18n < I18n
    def load_yaml1(lang, script)
      case lang
      when "en", "fr", "ru", "de", "es", "ar", "ja"
        load_yaml2(lang)
      when "zh"
        case script
        when "Hans", "Hant" then load_yaml2("zh-#{script}")
        else load_yaml2("zh-Hans")
        end
      else load_yaml2("en")
      end
    end

    def load_yaml2(str)
      YAML.load_file(File.join(File.dirname(__FILE__),
                               "../isodoc-yaml/i18n-#{str}.yaml"))
    end

    # force bidi for all i18n strings in Arabic,
    # because of the potential for script mixing
    def cleanup_entities(hash, is_xml: true)
      ret = super
      if @lang == "ar" && ret.include?("%")
        ret = "&#x61c;#{ret}&#x61c;"
      end
      ret
    end
  end
end
