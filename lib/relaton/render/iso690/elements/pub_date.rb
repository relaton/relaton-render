# frozen_string_literal: true

module Relaton
  module Render
    module Iso690
      module Elements
        # Date of publication (ISO 690 clause 7.7). The relaton model
        # provides typed date values (StringDate::Value#to_date); years
        # come from the model, never from string manipulation. A from/to
        # pair renders as a range (closed or open).
        class PubDate < Element
          def present?
            !render.nil?
          end

          # The bare date; the style's dateForm wraps it in the
          # dategroup slot (Fields#dategroup_field)
          def render
            range || year&.to_s
          end

          private

          def publication_date
            Array(@model.date).find(&:published) ||
              Array(@model.date).find { |d| d.type.nil? } ||
              Array(@model.date).find { |d| d.type == "created" } ||
              Array(@model.date).find { |d| d.type == "issued" } ||
              Array(@model.date).find { |d| d.type == "circulated" }
          end

          def publication_date_value
            d = publication_date or return nil
            d.from || d.at || d.to
          end

          def range
            d = publication_date or return nil
            dash = @i18n.label("date_range")
            if d.from && d.to
              fy = d.from.to_date.year
              ty = d.to.to_date.year
              fy == ty ? fy.to_s : "#{fy}#{dash}#{ty}"
            elsif d.from
              "#{d.from.to_date.year}#{dash}"
            end
          end

          def year
            publication_date_value.to_date.year
          rescue ArgumentError, TypeError, NoMethodError
            nil
          end
        end
      end
    end
  end
end
