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
            form = uri_form
            text = if form && !form.empty?
                     ::Relaton::Render::Iso690::Template.new(form).evaluate(
                       "uri" => Template::Field[!uri.empty?, uri],
                     )
                   else
                     uri
                   end

            label = @short ? "" : "#{@i18n.label('available_from')} "
            "#{label}#{text}".strip
          end

          private

          # The short cite renders the bare uri (1.x short templates),
          # the reference the declared form
          def uri_form
            if @short
              short_form = @style.templates.uri_short
              return :bare if short_form.empty?

              return short_form
            end

            @style.templates.uri
          end

          def uri
            from_accesslocation =
              Array(@model.accesslocation).map(&:to_s).reject(&:empty?)
            unless from_accesslocation.empty?
              return from_accesslocation.first.to_s
            end

            uris = Array(@model.source).reject do |u|
              u.content.to_s.strip.empty?
            end
            # the citation uri outranks the rest (1.x uri extraction)
            preferred = uris.find { |u| u.type == "citation" } ||
              uris.find { |u| u.type == "attachment" } || uris.first
            preferred&.content.to_s
          end
        end
      end
    end
  end
end
