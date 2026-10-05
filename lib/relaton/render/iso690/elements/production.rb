# frozen_string_literal: true

module Relaton
  module Render
    module Iso690
      module Elements
        # Production information: place and publisher (ISO 690 clause 7.8).
        # Place comes from the model's typed city; publishers from
        # organization contributors.
        class Production < Element
          def present?
            !places.empty? || !publishers.empty?
          end

          def render
            [places.join("; "), publishers.join("; ")]
              .reject(&:empty?).join(@i18n.punct_fetch("production_sep", ": "))
          end

          private

          def places
            Array(@model.place).map do |p|
              structured = [p.city.to_s, p.region.map(&:content),
                            p.country.map(&:content)]
                .flatten.reject { |c| c.strip.empty? }
              if structured.empty? && !p.formatted_place.to_s.empty?
                next p.formatted_place.to_s
              end

              structured.join(", ")
            end.reject(&:empty?)
          end

          def publishers
            contributors("publisher").map do |c|
              Array(c.organization&.name).map { |n| localized(n) }.join(", ")
            end.reject(&:empty?)
          end
        end
      end
    end
  end
end
