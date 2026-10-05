# frozen_string_literal: true

module Relaton
  module Render
    module Iso690
      module Elements
        # Extent of the item (ISO 690 clause 7.11): page localities.
        class Extent < Element
          def present?
            !render.empty?
          end

          def render
            groups = [numeration, page_range].reject { |g| g.empty? }
            groups.join(", ")
          end

          private

          def numeration
            %w[volume issue].filter_map do |type|
              loc = localities.find { |l| l.type == type }
              next if loc.nil? || loc.reference_from.to_s.empty?

              "#{@i18n.label(type)} #{loc.reference_from}"
            end.join(" ")
          end

          def page_range
            loc = localities.find { |l| l.type == "page" } or return ""
            from = loc.reference_from.to_s
            to = loc.reference_to.to_s
            if to.empty? || to == from
              "#{@i18n.label('page')} #{from}"
            else
              "#{@i18n.label('pages')} " \
                "#{from}#{@i18n.label('date_range')}#{to}"
            end
          end

          def localities
            Array(@model.extent).flat_map do |e|
              Array(e.locality) +
                Array(e.locality_stack).flat_map { |s| Array(s.locality) }
            end
          end
        end
      end
    end
  end
end
