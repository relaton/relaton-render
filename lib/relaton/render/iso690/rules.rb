# frozen_string_literal: true

module Relaton
  module Render
    module Iso690
      # The named-rule registry: presentation-of-models implementations
      # the engine ships once, addressable from pack data as
      # rules: { slot: rule_name }. Flavors migrate their ELEMENTS maps
      # onto registered rules; nothing references a flavor class.
      module Rules
        REGISTRY = {}

        class << self
          def register(name, klass)
            REGISTRY[name.to_s] = klass
          end

          # A pack's rule selections become the renderer's element map;
          # caller-supplied elements win over the pack's selections
          def resolve(rules, elements = {})
            Array(rules).to_h { |slot, name| [slot.to_sym, fetch(name)] }
              .merge(elements || {})
          end

          private

          def fetch(name)
            REGISTRY.fetch(name.to_s) do
              raise ArgumentError, "unknown citation style rule #{name}"
            end
          end
        end
      end
    end
  end
end
