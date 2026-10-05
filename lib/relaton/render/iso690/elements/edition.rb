# frozen_string_literal: true

module Relaton
  module Render
    module Iso690
      module Elements
        # Edition and version (ISO 690 clause 7.6). The model numbers the
        # edition through Edition#number (falling back to its content).
        class Edition < Element
          def present?
            !number.zero?
          end

          def render
            word = @i18n.label("edition_#{number}")
            return word unless word == "edition_#{number}"

            "#{ordinalize(number)} #{@i18n.label('edition')}"
          end

          private

          def number
            raw = @model.edition&.number || @model.edition&.content
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
