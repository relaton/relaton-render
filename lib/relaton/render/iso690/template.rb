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
          @slots = []
          @terminator = ""
          scan(source.to_s)
        end

        # The short cite renders the reference with the first-biblio
        # marker appended to its first component: isodoc's styled
        # references (eref2linkshort) split there (the 1.x
        # fmt-first-biblio-delim)
        def evaluate_short(fields, delim)
          rendered = @slots.filter_map do |(name, head, tail)|
            field = fields[normalise(name)] or next
            next unless field.present?

            [head, field.text, tail]
          end
          return "" if rendered.empty?

          parts = rendered.each_with_index.map do |(head, text, tail), i|
            if i.zero?
              # the split marker precedes the component's trailing
              # punctuation (1.x ret[0] += delim, then join), with the
              # join's separating space
              "#{head}#{text}#{delim} #{tail}"
            elsif i == rendered.size - 1
              "#{head}#{text}"
            else
              "#{head}#{text}#{tail}"
            end
          end
          terminate(parts.join).rstrip
        end

        def evaluate(fields)
          rendered = @slots.filter_map do |(name, head, tail)|
            field = fields[normalise(name)] or next
            next unless field.present?

            [head, field.text, tail]
          end
          return "" if rendered.empty?

          terminate(rendered.each_with_index.map do |(head, text, tail), i|
            i == rendered.size - 1 ? "#{head}#{text}" : "#{head}#{text}#{tail}"
          end.join).rstrip
        end

        private

        def scan(source)
          rest = source
          while (slot = SLOT.match(rest))
            head = @slots.empty? ? rest[0...slot.begin(0)] : ""
            @slots << [slot[1], head, ""]
            rest = rest[slot.end(0)..]
            following = SLOT.match(rest)
            boundary = following ? following.begin(0) : rest.length
            literal = rest[0...boundary]
            if following
              @slots.last[2] = literal
            else
              @terminator = literal
            end
            rest = rest[boundary..]
          end
        end

        def terminate(body)
          # 1.x punctuation cleanup: an element ending in a colon
          # carries its own separator (the following sentence period
          # collapses), and spaces collapse before a comma
          body = body.gsub(/:\s*\.\s*/, ": ").gsub(/ +,/, ",")
          return body if @terminator.strip.empty?
          return body if body.rstrip.end_with?(@terminator.strip)

          "#{body}#{@terminator}"
        end

        def normalise(slot)
          slot.to_s.delete("_").downcase
        end
      end
    end
  end
end
