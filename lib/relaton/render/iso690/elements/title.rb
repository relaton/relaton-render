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
            "#{@style.templates.title_open}#{main_title}" \
              "#{@style.templates.title_close}"
          end

          private

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
