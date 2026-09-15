# frozen_string_literal: true

module Relaton
  module Render
    module Iso690
      module Kinds
        # Continuing resources (ISO 690 clause 8.4): serials and their
        # component parts, per the clause 8.4 element table order
        class Continuing < Kinds::ComponentPart
          stack [
            %i[creator required],
            %i[title required],
            [:component_part,
             { if: ->(m) {
               Array(m.relation).any? do |r|
                 r.type == "partOf"
               end
             } }],
            %i[medium optional],
            %i[edition optional],
            %i[production required],
            %i[date required],
            %i[numeration optional],
            %i[identifier optional],
            %i[location optional],
          ]
        end
      end
    end
  end
end
