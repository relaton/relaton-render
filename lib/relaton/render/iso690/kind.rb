# frozen_string_literal: true

module Relaton
  module Render
    module Iso690
      # A resource type (ISO 690 clause 8): an ordered stack of data
      # elements, each with a status — :required, { if: proc }, or
      # :optional (default). Non-present elements are omitted at the
      # model level; required-but-absent elements are reported.
      class Kind
        class << self
          # DSL: stack [ [:creator, :required], [:title, :required], ... ]
          def stack(elements)
            @stack = elements
          end

          def resolves?(_model)
            false
          end

          def element_stack
            @stack || []
          end
        end

        def initialize(model, style:, i18n:)
          @model = model
          @style = style
          @i18n = i18n
          @missing_required = []
        end

        attr_reader :missing_required

        def render
          self.class.element_stack.filter_map do |(name, status)|
            element = Elements.build(name, @model, style: @style, i18n: @i18n)
            unless element.present?
              required_missing(name, status)
              next
            end
            "#{element.render}#{@style.punct(name.to_s)}"
          end.join.strip
        end

        private

        def required_missing(name, status)
          case status
          when :required then @missing_required << name
          when Hash then @missing_required << name if status[:if].call(@model)
          end
        end
      end
    end
  end
end
