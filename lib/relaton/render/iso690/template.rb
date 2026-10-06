# frozen_string_literal: true

module Relaton
  module Render
    module Iso690
      # A citation template as declared in a style instance: literal text
      # interleaved with {{slot}} placeholders resolved against the ISO 690
      # data element inventory. A leading literal attaches to the first
      # slot, and a literal between two slots to the preceding one, so an
      # absent field never orphans punctuation around it. The last rendered
      # slot gives up its trailing literal in favour of the template
      # terminator, appended once when any field rendered and the output
      # does not already end with it.
      class Template
        SLOT = /\{\{\s*([\w-]+)\s*\}\}/.freeze

        Field = Struct.new(:present?, :text)

        def initialize(source)
          @chunks = []
          @terminator = ""
          scan(source.to_s)
        end

        # The short cite renders the reference with the first-biblio
        # marker appended to its first component: isodoc's styled
        # references (eref2linkshort) split there (the 1.x
        # fmt-first-biblio-delim)
        def evaluate_short(fields, delim)
          present = present_indices(fields)
          return "" if present.empty?

          out = +""
          first_seen = false
          @chunks.each_with_index do |(kind, value), i|
            text =
              case kind
              when :slot
                field = fields[normalise(value)]
                next unless field&.present?

                first_seen ? field.text : "#{field.text}#{delim} "
              else
                # the split marker precedes the component's trailing
                # punctuation (1.x ret[0] += delim, then join), with
                # the join's separating space
                next unless bridged?(i, present)

                value
              end
            first_seen = true if @chunks[i].first == :slot
            out << text unless text.nil?
          end
          terminate(out).rstrip
        end

        # 1.x segment-join semantics: present elements joined with the
        # template's separators — a literal renders only when it
        # separates (a run of absent elements between) two present
        # elements; leading and trailing literals drop with the
        # elements they would have attached to
        def evaluate(fields)
          present = present_indices(fields)
          return "" if present.empty?

          out = +"".dup
          @chunks.each_with_index do |(kind, value), i|
            if kind == :slot
              field = fields[normalise(value)]
              out << field.text if field&.present?
            elsif bridged?(i, present) ||
                  (value.include?("<") && present.any? { |j| j < i })
              # markup attaches to the element it closes
              out << value
            elsif close_pending_paren?(out, value)
              out << value
            end
          end
          terminate(out).rstrip
        end

        private

        def scan(source)
          rest = source
          while (slot = SLOT.match(rest))
            @chunks << [:text, rest[0...slot.begin(0)]] if
              slot.begin(0).positive?
            @chunks << [:slot, slot[1]]
            rest = rest[slot.end(0)..]
          end
          @terminator = rest
        end

        def present_indices(fields)
          @chunks.each_index.select do |i|
            kind, value = @chunks[i]
            next false unless kind == :slot

            field = fields[normalise(value)]
            !field.nil? && field.present?
          end
        end

        # A literal bridges two present elements when at least one
        # present element stands on each side of it; a leading literal
        # (no slot precedes it) attaches to the first slot, emitting
        # only when that slot is present
        def bridged?(index, present)
          first_slot = @chunks.index { |(kind, _)| kind == :slot }
          return present.include?(first_slot) if index < first_slot

          present.any? { |i| i < index } && present.any? { |i| i > index }
        end

        # A template's paired literal ("({{production}})") closes even
        # when nothing follows the present element it wraps
        def close_pending_paren?(out, value)
          value.start_with?(")") && out.count("(") > out.count(")")
        end

        def terminate(body)
          # 1.x punctuation cleanup: a sentence period before a spaced
          # comma yields to the comma (", 2013" over ". , 2013"; an
          # initials period before a comma ("P.,") stands, being
          # unspaced), and stacked separators around absent elements
          # collapse into one (". : ." into ". "); an empty pair left
          # by an absent element drops
          body = body.gsub(/:\s*\.\s*/, ": ")
          body = body.gsub(/\.\s+,/, ",")
          body = body.gsub(/(?:[.,:;]\s+)+[.,:;]/, ". ")
          body = body.gsub(/\.\s*\./, ". ")
          body = body.gsub(/:\s*\.\s*/, ": ")
          body = body.gsub(/\(\s*\)/, "")
          body = body.gsub(/ +/, " ").gsub(" ,", ",")
          terminator = unbalanced_close(body, @terminator)
          return body if terminator.strip.empty?
          if terminator !~ /[<\w]/ && body.rstrip.end_with?(terminator.strip)
            return body
          end

          "#{body}#{terminator}"
        end

        # The terminator's closing parens stand only when the body
        # opened them (their "(" died with an absent element)
        def unbalanced_close(body, terminator)
          return terminator unless terminator.start_with?(")")

          open = body.count("(") - body.count(")")
          return terminator.sub(/\A\)+/) { |closes| closes[0, open] } if
            open.positive?

          terminator.sub(/\A\)+/, "")
        end

        def normalise(slot)
          slot.to_s.delete("_").downcase
        end
      end
    end
  end
end
