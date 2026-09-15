# frozen_string_literal: true

module Relaton
  module Render
    module Iso690
      module Kinds
        # Patents (ISO 690 clause 8.10)
        class Patent < Kinds::Report
          stack [
            %i[creator required],
            %i[title required],
            %i[identifier required],
            %i[date required],
          ]
        end
      end
    end
  end
end
