require_relative "../utils/utils"
require_relative "liquid"

module Relaton
  module Render
    module Template
      class General
        def initialize(opt = {})
          @htmlentities = HTMLEntities.new
          customise_liquid
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

        def customise_liquid
          ::Liquid::Template
            .register_filter(::Relaton::Render::Template::CapitalizeFirst)
        end

        # denote start and end of field,
        # so that we can detect empty fields in postprocessing
        FIELD_DELIM = "\u0018".freeze

        # escape < >
        LT_DELIM = "\u0019".freeze
        GT_DELIM = "\u001a".freeze

        # use tab internally for non-spacing delimiter
        NON_SPACING_DELIM = "\t".freeze

        def template_process(template)
          t = template.gsub(/\{\{/, "#{FIELD_DELIM}{{")
            .gsub(/\}\}/, "}}#{FIELD_DELIM}")
            .gsub(/\t/, " ")
          t1 = t.split(/(\{\{.+?\}\})/).map do |n|
            n.include?("{{") ? n : n.gsub(/(?<!\\)\|/, "\t")
          end.join
          ::Liquid::Template.parse(t1)
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
            .gsub(/([,:;]\s*)+([,:;](\s|$))/, "\\2")
            .gsub(/([,.:;]\s*)+([.](\s|$))/, "\\2")
            .gsub(/([,:;]\s*)+(,(\s|$))/, "\\2")
            .gsub(/(:\s+)(&\s)/, "\\2")
            .gsub(/\s+([,.:;)])/, "\\1")
            .sub(/^\s*[,.:;]\s*/, "")
            .sub(/[,:;]\s*$/, "")
            .gsub(/(?<!\\)_/, " ")
            .gsub(/\\_/, "_")
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
            hash.empty? ? nil : hash.gsub(/ /, "_")
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
          opt[:template].delete("etal_count")
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
          if @etal_count && names[:surname].size >= @etal_count
            @template[:etal]
          else expand_nametemplate(@template_raw[:more], names[:surname].size)
          end
        end

        # assumes that template contains, consecutively and not interleaved,
        # ...[0], ...[1], ...[2]
        def expand_nametemplate(template, size)
          t = nametemplate_split(template)
          mid = (1..size - 2).each_with_object([]) do |i, m|
            m << t[1].gsub(/\[1\]/, "[#{i}]")
          end
          template_process(t[0] + mid.join + t[2].gsub(/\[2\]/,
                                                       "[#{size - 1}]"))
        end

        def nametemplate_split(template)
          curr = 0
          prec = ""
          t = template.split(/(\{[{%].+?[}%]\})/)
            .each_with_object(["", "", ""]) do |n, m|
            m, curr, prec = nametemplate_split1(n, m, curr, prec)

            m
          end
          t[-1] += prec
          t
        end

        def nametemplate_split1(elem, acc, curr, prec)
          if match = /\{[{%].+?\[(\d)\]/.match(elem)
            curr += 1 if match[1].to_i > curr
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
