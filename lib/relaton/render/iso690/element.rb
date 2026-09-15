# frozen_string_literal: true

module Relaton
  module Render
    module Iso690
      # Base data element (ISO 690 clause 7). An element wraps typed data
      # taken from the relaton model instance; #present? is the omission
      # predicate, #render the element's formatting method. Punctuation
      # between elements belongs to the kind/style, not the element.
      class Element
        def initialize(model, style:, i18n:)
          @model = model
          @style = style
          @i18n = i18n
        end

        def present?
          false
        end

        def render
          nil
        end

        private

        def localized(value)
          value&.content.to_s
        end

        def contributors(role)
          Array(@model.contributor).select { |c| has_role?(c, role) }
        end

        def has_role?(contributor, role)
          Array(contributor.role).any? do |r|
            r.is_a?(String) ? r == role : r.type == role
          end
        end
      end
    end
  end
end
