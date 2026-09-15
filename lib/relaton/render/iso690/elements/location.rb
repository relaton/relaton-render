# frozen_string_literal: true

module Relaton
  module Render
    module Iso690
      module Elements
        # Availability and location (ISO 690 clause 7.12): access location
        # (URI) of the resource
        class Location < Element
          def present?
            !uri.empty?
          end

          def render
            "#{@i18n.label('available_from')} #{uri}"
          end

          private

          def uri
            Array(@model.accesslocation).reject(&:empty?).first.to_s
          end
        end
      end
    end
  end
end
