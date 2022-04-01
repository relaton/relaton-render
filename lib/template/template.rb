require_relative "../utils/utils"

module Relaton
  module Render
    class Iso690Template
      def initialize(opt = {})
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

      # denote start and end of field,
      # so that we can detect empty fields in postprocessing
      FIELD_DELIM = "\u0018".freeze

      # use tab internally for non-spacing delimiter
      NON_SPACING_DELIM = "\t".freeze

      def template_process(template)
        t = template.gsub(/\{\{/, "#{FIELD_DELIM}{{")
          .gsub(/\}\}/, "}}#{FIELD_DELIM}")
          .gsub(/\t/, " ")
        t1 = t.split(/(\{\{.+?\}\})/).map do |n|
          n.include?("{{") ? n : n.gsub(/(?<!\\)\|/, "\t")
        end.join
        Liquid::Template.parse(t1)
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
        str = str.gsub(/\S*#{FIELD_DELIM}#{FIELD_DELIM}\S*/o, "")
          .gsub(/#{FIELD_DELIM}/o, "")
          .gsub(/_/, " ")
          .gsub(/([,:;]\s*)+([,:;](\s|$))/, "\\2")
          .gsub(/([,.:;]\s*)+([.](\s|$))/, "\\2")
          .gsub(/(:\s+)(&\s)/, "\\2")
          .gsub(/\s+([,.:;])/, "\\1")
          .gsub(/#{NON_SPACING_DELIM}/o, "").gsub(/\s+/, " ")
        str.strip
      end

      def liquid_hash(hash)
        case hash
        when Hash
          hash.map { |k, v| [k.to_s, liquid_hash(v)] }.to_h
        when Array
          hash.map { |v| liquid_hash(v) }
        when String
          hash.empty? ? nil : hash
        else hash
        end
      end
    end

    class Iso690SeriesTemplate < Iso690Template
    end

    class Iso690ExtentTemplate < Iso690Template
      def template_select(hash)
        t = @template_raw[hash[:type].to_sym]
        hash.each do |k, _v|
          next unless hash[:orig][k].is_a?(Hash)

          num = number(hash[:type], hash[:orig][k])
          t = t.gsub(/labels\[['"]extent['"]\]\[['"]#{k}['"]\]/,
                     "\\0['#{num}']")
        end
        t = t.gsub(/labels\[['"]extent['"]\]\[['"][^\]'"]+['"]\](?!\[)/,
                   "\\0['sg']")
        template_process(t)
      end

      def number(type, value)
        return "pl" if value[:to]
        return "sg" if %w(article incollection inproceedings inbook)
          .include?(type) || value[:host_title]

        value[:from] == "1" ? "sg" : "pl"
      end
    end

    class Iso690NameTemplate < Iso690Template
      def initialize(opt = {})
        @etal_count = opt[:template]["etal_count"]
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
          else expand_nametemplate(@template_raw[:more], names.size)
          end
        end
      end

      # assumes that template contains, consecutively and not interleaved,
      # ...[0], ...[1], ...[2]
      def expand_nametemplate(template, size)
        t = nametemplate_split(template)
        mid = (1..size - 1).each_with_object([]) do |i, m|
          m << t[1].gsub(/\[1\]/, "[#{i}]")
        end
        template_process(t[0] + mid.join + t[2].gsub(/\[2\]/, "[#{size}]"))
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
        if match = /\{\{.+?\[(\d)\]/.match(elem)
          curr += 1 if match[1].to_i > curr
          acc[curr] += prec
          prec = ""
          acc[curr] += elem
        else prec += elem
        end
        [acc, curr, prec]
      end
    end
  end
end
