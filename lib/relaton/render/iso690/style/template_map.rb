# frozen_string_literal: true

module Relaton
  module Render
    module Iso690
      class Style
        # TemplateMap: citation and reference templates as data, plus the
        # title emphasis markers and the first-creator name form. Slots
        # name ISO 690 clause 7 data elements or name-form fields.
        class TemplateMap < Lutaml::Model::Serializable
          attribute :title_open, :string, default: "_"
          attribute :title_close, :string, default: "_"
          attribute :citation, :string, default: "{{surname}}, {{date}}"
          attribute :reference, :string
          attribute :name, :string, default: "{{surname}}, {{givenNames}}"

          key_value do
            map "titleOpen", to: :title_open
            map "titleClose", to: :title_close
            map "citation", to: :citation
            map "reference", to: :reference
            map "name", to: :name
          end
        end
      end
    end
  end
end
