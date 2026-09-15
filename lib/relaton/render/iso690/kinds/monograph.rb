# frozen_string_literal: true

module Relaton
  module Render
    module Iso690
      module Kinds
        # Monographs (ISO 690 clause 8.2): table order transcribed
        class Monograph < Kind
          stack [
            %i[creator required],
            %i[title required],
            [:medium, { if: ->(m) { m.type != "book" } }],
            %i[edition optional],
            %i[series optional],
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
