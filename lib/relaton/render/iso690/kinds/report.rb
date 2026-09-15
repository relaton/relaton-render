# frozen_string_literal: true

module Relaton
  module Render
    module Iso690
      module Kinds
        # Reports (ISO 690 clause 8.11) — fallback kind
        class Report < Kinds::Monograph
          stack [
            %i[creator required],
            %i[title required],
            %i[numeration optional],
            %i[edition optional],
            %i[series optional],
            %i[production optional],
            %i[date required],
            %i[identifier optional],
            %i[location optional],
          ]
        end
      end
    end
  end
end
