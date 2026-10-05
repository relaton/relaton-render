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
          date numeration component_part identifier location size
          extent access stddoc status citeid updated
        ].freeze

        def initialize(model, style:, i18n:, disambiguator: nil,
                       short: false)
          @model = model
          @style = style
          @i18n = i18n
          @disambiguator = disambiguator.to_s
          @short = short
        end

        def to_h
          table = {}
          ELEMENT_SLOTS.each do |slot|
            key = slot.to_s.delete("_").downcase
            table[key] = element_field(slot)
          end
          table["dategroup"] = dategroup_field
          table.merge(name_fields)
        end

        private

        # The date wrapped in the style's dateForm, with the updated
        # date nested ("(2018 (updated November 2018))"); the bare date
        # slot stays untouched
        def dategroup_field
          form = @style.templates.date_form
          return Template::Field[false, ""] if form.empty?

          date = element_field(:date)
          updated = element_field(:updated)
          text = ::Relaton::Render::Iso690::Template.new(form).evaluate(
            "date" => date, "updated" => updated,
          )
          Template::Field[date.present? || updated.present?, text]
        end

        private

        def element_field(slot)
          element = Elements.build(slot, @model, style: @style,
                                   i18n: @i18n, short: @short)
          text = element.render.to_s
          if element.present? && !text.empty?
            return Template::Field[true, text]
          end

          fallback = @style.fallback_for(item_kind, slot)
          return Template::Field[true, fallback] if fallback

          Template::Field[false, ""]
        end

        def item_kind
          Kinds.kind_for(@model.type)
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
