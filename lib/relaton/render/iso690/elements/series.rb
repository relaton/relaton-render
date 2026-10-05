# frozen_string_literal: true

module Relaton
  module Render
    module Iso690
      module Elements
        # Series title and number (ISO 690 clause 7.10)
        class Series < Element
          def present?
            !series_title.empty?
          end

          def render
            if (form = @style.templates.series) && !form.empty?
              return ::Relaton::Render::Iso690::Template.new(form).evaluate(
                "series_title" => Template::Field[!series_title.empty?,
                                                  series_title],
                "series_number" => Template::Field[!number.empty?, number],
              )
            end

            base = "#{@style.templates.title_open}#{series_title}" \
                   "#{@style.templates.title_close}"
            if number.empty?
              base
            else
              "#{base}, #{@i18n.label('series_no')} #{number}"
            end
          end

          private

          def series
            Array(@model.series).first
          end

          def series_title
            Array(series&.title).map { |t| localized(t) }.join(" ").strip
          end

          def number
            series&.number.to_s
          end
        end
      end
    end
  end
end
