# frozen_string_literal: true

module Relaton
  module Render
    module Iso690
      module Kinds
        # Online resources (ISO 690 clause 8.14)
        class Online < Kinds::Report
          stack [
            %i[creator required],
            %i[title required],
            %i[date required],
            %i[identifier optional],
            [:location, { if: ->(_m) { true } }],
          ]
        end
      end
    end
  end
end
