# frozen_string_literal: true

module Relaton
  module Render
    module Iso690
      module Elements
        # Title of the resource (ISO 690 clause 7.3), emphasised by the
        # style's declared title markers
        class Title < Element
          def present?
            !main_title.empty?
          end

          def render
            text = main_title
            return text if analytic?
            if (form = @style.title_form_for(Kinds.kind_for(@model.type)))
              text = ::Relaton::Render::Iso690::Template.new(form).evaluate(
                "title" => Template::Field[!text.empty?, text],
              )
            end

            "#{@style.templates.title_open}#{text}" \
              "#{@style.templates.title_close}"
          end

          private

          # ISO 690: analytic titles are not emphasised; the host or
          # serial carries the emphasis
          def analytic?
            %w[component_part serial_part]
              .include?(Kinds.kind_for(@model.type))
          end

          def main_title
            t = Array(@model.title).find { |x| (x.type || "main") == "main" } ||
              Array(@model.title).first
            localized(t)
          end
        end
      end
    end
  end
end
