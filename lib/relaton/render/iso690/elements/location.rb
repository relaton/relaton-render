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
            text = if (form = @style.templates.uri) && !form.empty?
                     ::Relaton::Render::Iso690::Template.new(form).evaluate(
                       "uri" => Template::Field[!uri.empty?, uri],
                     )
                   else
                     uri
                   end

            "#{@i18n.label('available_from')} #{text}".strip
          end

          private

          def uri
            from_accesslocation =
              Array(@model.accesslocation).map(&:to_s).reject(&:empty?)
            unless from_accesslocation.empty?
              return from_accesslocation.first.to_s
            end

            Array(@model.source).map { |u| u.content.to_s }
              .reject(&:empty?).first.to_s
          end
        end
      end
    end
  end
end
