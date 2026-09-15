# frozen_string_literal: true

module Relaton
  module Render
    module Iso690
      module Elements
        # Medium designation (ISO 690 clause 7.5), e.g. "online resource"
        class Medium < Element
          def present?
            !medium.empty?
          end

          def render
            medium
          end

          private

          def medium
            localized(@model.medium)
          end
        end
      end
    end
  end
end
