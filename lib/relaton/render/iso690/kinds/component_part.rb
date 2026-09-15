# frozen_string_literal: true

module Relaton
  module Render
    module Iso690
      module Kinds
        # Parts of monographs (ISO 690 clause 8.3)
        class ComponentPart < Kinds::Monograph
          stack [
            %i[creator required],
            %i[title required],
            %i[component_part required],
            %i[edition optional],
            %i[production required],
            %i[date required],
            %i[identifier optional],
            %i[location optional],
          ]
        end
      end
    end
  end
end
