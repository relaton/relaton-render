# frozen_string_literal: true

module Relaton
  module Render
    module Iso690
      # Field resolver: builds the template evaluator's field table from a
      # relaton model instance. Slots resolve to ISO 690 clause 7 data
      # elements, to name-form fields of the principal creator, or to the
      # disambiguator supplied by the citation caller.
      class Fields
        ELEMENT_SLOTS = %i[
          creator title edition medium series production
          date numeration component_part identifier location
        ].freeze

        def initialize(model, style:, i18n:, disambiguator: nil)
          @model = model
          @style = style
          @i18n = i18n
          @disambiguator = disambiguator.to_s
        end

        def to_h
          table = {}
          ELEMENT_SLOTS.each do |slot|
            key = slot.to_s.delete("_").downcase
            table[key] = element_field(slot)
          end
          table.merge(name_fields)
        end

        private

        def element_field(slot)
          element = Elements.build(slot, @model, style: @style, i18n: @i18n)
          text = element.render.to_s
          Template::Field[element.present? && !text.empty?, text]
        end

        def name_fields
          creator = Elements.build(:creator, @model, style: @style, i18n: @i18n)
          {
            "surname" => Template::Field[creator.present?, creator.in_text],
            "givennames" => Template::Field[!creator.principal_given.empty?,
                                            creator.principal_given],
            "disambiguator" => Template::Field[!@disambiguator.empty?,
                                               @disambiguator],
          }
        end
      end
    end
  end
end
