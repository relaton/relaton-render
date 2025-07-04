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

        # denote start and end of field,
        # so that we can detect empty fields in postprocessing
        # FIELD_DELIM = "\u0018".freeze
        FIELD_DELIM = "%%".freeze

        # escape < >
        LT_DELIM = "\u0019".freeze
        GT_DELIM = "\u001a".freeze

        # use tab internally for non-spacing delimiter
        NON_SPACING_DELIM = "\t".freeze

        def punct_field?(name)
          name or return false
          name = name.tr("'", '"')
          %w(labels["qq-open"] labels["qq-close"] labels["q-open"]
             labels["q-close"]).include?(name)
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
              a[1] = "#{FIELD_DELIM}{{"
              a[3] = "}}#{FIELD_DELIM}"
            end
            a.join
          end.join.tr("\t", " ")
          t.gsub(/\}\}#{FIELD_DELIM}\|/o, "}}#{FIELD_DELIM}\t")
            .gsub(/\|#{FIELD_DELIM}\{\{/o, "\t#{FIELD_DELIM}{{")
        end

        def render(hash)
          t = template_select(hash) or return nil

          template_clean(t.render(liquid_hash(hash.merge("labels" => @i18n.get))))
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

        # use tab internally for non-spacing delimiter
        def template_clean1(str)
          str.gsub(/\S*#{FIELD_DELIM}#{FIELD_DELIM}\S*/o, "")
            .gsub(/#{FIELD_DELIM}/o, "")
            .gsub(/([,:;]\s*)+([,:;](\s|_|$))/, "\\2")
            .gsub(/([,.:;]\s*)+([.](\s|_|$))/, "\\2")
            .gsub(/([,:;]\s*)+(,(\s|_|$))/, "\\2")
            .gsub(/(:\s+)(&\s)/, "\\2")
            .gsub(/\s+([,.:;)])/, "\\1")
            .sub(/^\s*[,.:;]\s*/, "")
            .sub(/[,:;]\s*$/, "")
            .gsub(/(?<!\\)_/, " ")
            .gsub("\\_", "_")
            .gsub(/#{NON_SPACING_DELIM}/o, "").gsub(/\s+/, " ")
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

      class Series < General
      end

      class Extent < General
        def template_select(hash)
          @template[hash[:type].to_sym]
        end
      end

      class Size < General
        def template_select(hash)
          @template[hash[:type].to_sym]
        end
      end

      class Name < General
        def initialize(opt = {})
          @etal_count = opt[:template]["etal_count"]
          @etal_display = opt[:template]["etal_display"] || @etal_count
          opt[:template].delete("etal_count")
          opt[:template].delete("etal_display")
          super
        end

        def template_select(names)
          return nil if names.nil? || names.empty?

          case names[:surname].size
          when 1 then @template[:one]
          when 2 then @template[:two]
          when 3 then @template[:more]
          else template_select_etal(names)
          end
        end

        def template_select_etal(names)
          if @etal_count && names[:surname].size > @etal_count
            expand_nametemplate(@template_raw[:etal], @etal_display)
          else
            expand_nametemplate(@template_raw[:more], names[:surname].size)
          end
        end

        # assumes that template contains, consecutively and not interleaved,
        # ...[0], ...[1], ...[2]
        def expand_nametemplate(template, size)
          t = nametemplate_split(template)

          mid = (1..size - 2).each_with_object([]) do |i, m|
            m << t[1].gsub("[1]", "[#{i}]")
          end
          t[1] = mid.join
          t[2].gsub!(/\[\d+\]/, "[#{size - 1}]")
          template_process(combine_nametemplate(t, size))
        end

        def combine_nametemplate(parts, size)
          case size
          when 1 then parts[0] + parts[3]
          when 2 then parts[0] + parts[2] + parts[3]
          else parts.join
          end
        end

        def nametemplate_split(template)
          curr = 0
          prec = ""
          t = template.split(/(\{[{%].+?[}%]\})/)
            .each_with_object([""]) do |n, m|
            m, curr, prec = nametemplate_split1(n, m, curr, prec)

            m
          end
          [t[0], t[1], t[-1], prec]
        end

        def nametemplate_split1(elem, acc, curr, prec)
          if match = /\{[{%].+?\[(\d)\]/.match(elem)
            if match[1].to_i > curr
              curr += 1
              acc[curr] ||= ""
            end
            acc[curr] += prec
            prec = ""
            acc[curr] += elem
          elsif /\{%\s*endif/.match?(elem)
            acc[curr] += prec
            prec = ""
            acc[curr] += elem
          else prec += elem
          end
          [acc, curr, prec]
        end
      end

      class AuthorCite < Name
      end
    end
  end
end
