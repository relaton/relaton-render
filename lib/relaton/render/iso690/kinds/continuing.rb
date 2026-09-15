# frozen_string_literal: true

module Relaton
  module Render
    module Iso690
      module Kinds
        # Contributions to continuing resources (ISO 690 clause 8.4)
        class Continuing < Kinds::ComponentPart
          stack [
            %i[creator required],
            %i[title required],
            %i[component_part required],
            %i[date required],
            %i[identifier optional],
            %i[location optional],
          ]
        end
      end
    end
  end
end
