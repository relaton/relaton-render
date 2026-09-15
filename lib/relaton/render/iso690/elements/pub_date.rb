# frozen_string_literal: true

module Relaton
  module Render
    module Iso690
      module Elements
        # Date of publication (ISO 690 clause 7.7). The relaton model
        # provides typed date values (StringDate::Value#to_date); the year
        # comes from the model, never from string manipulation.
        class PubDate < Element
          def present?
            !year.nil?
          end

          def render
            year.to_s
          end

          private

          def publication_date
            Array(@model.date).find(&:published) ||
              Array(@model.date).find { |d| d.type.nil? }
          end

          def publication_date_value
            d = publication_date or return nil
            d.from || d.at || d.to
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
