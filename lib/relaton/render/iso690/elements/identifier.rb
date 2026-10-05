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
            return "" if identifiers.empty?

            ids = @style.templates.identifier_mode == "first" ?
              [identifiers.first] : identifiers
            ids.map { |d| IdentifierKinds.render(d) }
              .join(@i18n.punct_fetch("identifier_join", ". "))
          end

          private

          # Scoped identifiers (anchor, biblio-tag) are pipeline
          # artefacts, not cited identifiers
          def identifiers
            Array(@model.docidentifier).reject do |d|
              INTERNAL_TYPES.include?(d.type) ||
                !d.scope.to_s.empty? || d.content.to_s.strip.empty?
            end
          end
        end
      end
    end
  end
end
