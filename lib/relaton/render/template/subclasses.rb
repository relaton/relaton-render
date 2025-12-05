module Relaton
  module Render
    module Template
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
          @in_name = 0
          t = template.split(/(\{[{%][^{]+?[}%]\})/)
            .each_with_object([""]) do |n, m|
            m, curr, prec = nametemplate_split1(n, m, curr, prec)

            m
          end
          [t[0], t[1], t[-1], prec]
        end

        def nametemplate_split1(elem, acc, curr, prec)
          if match = /\{[{%].+?\[(\d)\]/.match(elem)
            # we are in a name component
            # if an if is started, track the if nesting...
            @in_name += 1 if /\{%\s*if/.match?(elem)
            if match[1].to_i > curr
              curr += 1
              acc[curr] ||= ""
            end
            acc[curr] += prec
            prec = ""
            acc[curr] += elem
          elsif /\{%\s*endif/.match?(elem) && @in_name.positive?
            # stick the endif to the currently if-nested name component,
            # if we are in one (@in_name.positive?)
            @in_name -= 1
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

      class Cite < General
        def template_select(hash)
          if hash[:citestyle].to_sym == :short
            @template[hash[:type].to_sym]
          else
            @template[hash[:citestyle].to_sym]
          end
        end

        def citation_styles
          @template.keys
        end
      end
    end
  end
end
