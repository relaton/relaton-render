# frozen_string_literal: true

module Relaton
  module Render
    module Iso690
      module Elements
        # Edition and version (ISO 690 clause 7.6). The model numbers the
        # edition through Edition#number (falling back to its content).
        class Edition < Element
          def present?
            !raw.to_s.empty?
          end

          def render
            return "#{@i18n.label('version')} #{raw}" unless word_edition?

            word = @i18n.label("edition_#{number}")
            return word unless word == "edition_#{number}"

            "#{ordinalize(number)} #{@i18n.label('edition')}"
          end

          private

          # Worded editions are document editions; online resources
          # carry numbered builds rendered as versions
          def word_edition?
            number.positive? &&
              %w[monograph component_part serial_part]
                .include?(item_kind)
          end

          def raw
            (@model.edition&.number || @model.edition&.content).to_s
          end

          def number
            Integer(raw)
          rescue ArgumentError, TypeError
            0
          end

          def ordinalize(num)
            "#{num}#{ordinal_suffix(num)}"
          end

          def ordinal_suffix(num)
            case num % 100
            when 11, 12, 13 then "th"
            else
              case num % 10
              when 1 then "st"
              when 2 then "nd"
              when 3 then "rd"
              else "th"
              end
            end
          end
        end
      end
    end
  end
end
