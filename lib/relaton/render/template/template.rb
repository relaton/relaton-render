require_relative "../utils/utils"
require_relative "liquid"
require "singleton"

module Relaton
  module Render
    module Template
      class CacheManager
        include Singleton

        attr_accessor :mutex

        def initialize
          @cache = {}
          @mutex = Mutex.new
        end

        def store(key, value)
          @cache[key] = value
        end

        def retrieve(key)
          @cache[key]
        end

        def clear
          @cache.clear
        end
      end

      class General
        attr_reader :template_raw

        def initialize(opt = {})
          @htmlentities = HTMLEntities.new
          @templatecache = CacheManager.instance
          @liquid_env = create_liquid_environment
          parse_options(opt)
        end

        def parse_options(opt)
          opt = Utils::sym_keys(opt)
          @i18n = opt[:i18n]
          @template_raw = opt[:template].dup
          @template =
            case opt[:template]
            when Hash
              opt[:template].transform_values { |x| template_process(x) }
            when Array then opt[:template].map { |x| template_process(x) }
            else { default: template_process(opt[:template]) }
            end
        end

        def create_liquid_environment
          env = ::Liquid::Environment.new
          env.register_filter(::Relaton::Render::Template::CustomFilters)
          env
        end

        # denote start and end of variable,
        # so that we can detect empty variables in postprocessing
        VARIABLE_DELIM = "%%".freeze

        # denote citation components which get delimited by period conventionally
        COMPONENT_DELIM = Regexp.quote("$$$").freeze

        # escape < >
        LT_DELIM = "\u0019".freeze
        GT_DELIM = "\u001a".freeze

        # use tab internally for non-spacing delimiter
        NON_SPACING_DELIM = "\t".freeze

        def punct_field?(name)
          name or return false
          name = name.tr("'", '"')
          %w(labels["punct"]["open-title"] labels["punct"]["close-title"]
             labels["punct"]["open-secondary-title"]
             labels["punct"]["close-secondary-title"]).include?(name)
        end

        def template_process(template)
          template.is_a?(String) or return template
          t = nil
          @templatecache.mutex.synchronize do
            unless t = @templatecache.retrieve(template)
              t = ::Liquid::Template
                .parse(add_field_delim_to_template(template), environment: @liquid_env)
              @templatecache.store(template, t)
            end
          end
          t
        end

        def add_field_delim_to_template(template)
          t = template.split(/(\{\{|\}\})/).each_slice(4).map do |a|
            unless !a[2] || punct_field?(a[2]&.strip)
              a[1] = "#{VARIABLE_DELIM}{{"
              a[3] = "}}#{VARIABLE_DELIM}"
            end
            a.join
          end.join.tr("\t", " ")
          t.gsub(/\}\}#{VARIABLE_DELIM}\|/o, "}}#{VARIABLE_DELIM}#{NON_SPACING_DELIM}")
            .gsub(/\|#{VARIABLE_DELIM}\{\{/o, "#{NON_SPACING_DELIM}#{VARIABLE_DELIM}{{")
        end

        def render(hash)
          t = template_select(hash) or return nil

          ret = template_clean(t.render(liquid_hash(hash.merge("labels" => @i18n.get))))
          template_components(ret,
                              @i18n.get.dig("punct", "biblio-field-delimiter") || ". ")
        end

        def template_select(_hash)
          @template[:default]
        end

        def template_clean(str)
          str = str.gsub(/&#x3c;/i, LT_DELIM).gsub(/&#x3e;/i, GT_DELIM)
          str = template_clean1(@htmlentities.decode(str))
          /[[:alnum:]]/.match?(str) or return nil
          str.strip.gsub(/#{LT_DELIM}/o, "&#x3c;")
            .gsub(/#{GT_DELIM}/o, "&#x3e;")
            .gsub(/&(?!#\S+?;)/, "&#x26;")
        end

        def template_clean1(str)
          str = strip_empty_variables(str)
          str.gsub(/([,:;]\s*)+<\/esc>([,:;])(\s|_|$)/, "\\2</esc>\\3")
            .gsub(/([,:;]\s*)+([,:;](\s|_|$))/, "\\2")
            .gsub(/([,.:;]\s*)+<\/esc>([.])(\s|_|$)/, "\\2</esc>\\3") # move outside
            .gsub(/([,.:;]\s*)+([.](\s|_|$))/, "\\2") # move outside
            .gsub(/([,:;]\s*)+<\/esc>(,)(\s|_|$)/, "\\2</esc>\\3")
            .gsub(/([,:;]\s*)+(,(\s|_|$))/, "\\2")
            .gsub(/(:\s+)(&\s)/, "\\2")
            .gsub(/\s+([,.:;)])/, "\\1") # trim around $$$
            .sub(/^\s*[,.:;]\s*/, "") # no init $$$
            .sub(/[,:;]\s*$/, "")
            .gsub(/(?<!\\)_/, " ")
            .gsub("\\_", "_")
            .gsub(/(?<!#{COMPONENT_DELIM})#{NON_SPACING_DELIM}(?!#{COMPONENT_DELIM})/o, "") # preserve NON_SPACING_DELIM near $$$
            .gsub(/[\n\r ]+/, " ")
            .gsub(/<(\/)?esc>/i, "<\\1esc>")
        end

        # get rid of all empty variables, and any text around them,
        # including component delimiters:
        # [{{}}]$$$ => ""
        # [{{}}] $$$ => " $$$"
        def strip_empty_variables(str)
          str.gsub(/\S*#{VARIABLE_DELIM}#{VARIABLE_DELIM}\S*/o, "")
            .gsub(/#{VARIABLE_DELIM}/o, "")
        end

        # delim = punct.biblio-field-terminator must not be i18n'ised:
        # .</esc>. deletes first .
        # .</esc>。does not delete first .
        # So we do not want to pass delim in as .,
        # and then have it i18n to 。after we are done parsing
        #
        # Do not strip any delimiters from final field in string
        #
        # if delim = ". " , then: ({{ series }}$$$|) => (series1.)
        def template_components(str, delim)
          str or return str
          delimrstrip, delimre, delimrstripre = template_components_prep(delim)
          ret = str.gsub(NON_SPACING_DELIM, "|").split(/#{COMPONENT_DELIM}/o)
            .map(&:strip).reject(&:empty?)
          ret = ret[0...-1].map do |s|
            s.sub(/#{delimre}$/, "").sub(%r[#{delimre}(</[^>]+>)$], "\\1")
          end + [ret.last]
          delim != delimrstrip and # "." in field followed by ". " in delim
            ret = remove_double_period(ret, delimrstripre)
          ret.join(delim).gsub(/#{delim}\|/, delimrstrip)
        end

        def remove_double_period(ret, delimrstripre)
          ret[0...-1].map do |s|
            s.sub(/#{delimrstripre}$/, "")
              .sub(%r[#{delimrstripre}(</[^>]+>)$], "\\1")
          end + [ret.last]
        end

        def template_components_prep(delim)
          [delim.rstrip, Regexp.quote(delim),
           # if delim is esc'd, ignore the escs in the preceding span
           Regexp.quote(delim.rstrip.gsub(%r{</?esc>}, ""))]
        end

        # need non-breaking spaces in fields: "Updated:_nil" ---
        # we want the "Updated:" deleted,
        # even if it's multiple words, as in French Mise_à_jour.
        def liquid_hash(hash)
          case hash
          when Hash
            hash.map { |k, v| [k.to_s, liquid_hash(v)] }.to_h
          when Array
            hash.map { |v| liquid_hash(v) }
          when String
            hash.empty? ? nil : hash.gsub("_", "\\_").tr(" ", "_")
          else hash
          end
        end
      end
    end
  end
end

require_relative "subclasses"
