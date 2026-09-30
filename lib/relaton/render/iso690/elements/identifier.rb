# frozen_string_literal: true

module Relaton
  module Render
    module Iso690
      module Elements
        # Standard and persistent identifiers, rendered by kind
        class Identifier < Element
          INTERNAL_TYPES = %w[metanorma metanorma-ordinal metanorma-objid]
            .freeze

          def present?
            !identifiers.empty?
          end

          def render
            identifiers.map { |d| IdentifierKinds.render(d) }
              .join(@i18n.punct_fetch("identifier_join", ". "))
          end

          private

          def identifiers
            Array(@model.docidentifier).reject do |d|
              INTERNAL_TYPES.include?(d.type) || d.content.to_s.strip.empty?
            end
          end
        end
      end
    end
  end
end
