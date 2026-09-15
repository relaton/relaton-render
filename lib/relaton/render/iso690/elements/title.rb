# frozen_string_literal: true

module Relaton
  module Render
    module Iso690
      module Elements
        # Title of the resource (ISO 690 clause 7.3), emphasised per style
        class Title < Element
          def present?
            !main_title.empty?
          end

          def render
            "#{@style.title_open}#{main_title}#{@style.title_close}"
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
