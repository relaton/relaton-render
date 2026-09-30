# frozen_string_literal: true

module Relaton
  module Render
    module Iso690
      class Style
        # How personal names are formed, as declared by the style's
        # citation scheme (relaton-models NameFormRules).
        class NameForm < Lutaml::Model::Serializable
          attribute :initials, :boolean, default: -> { false }
          attribute :given_name_first, :boolean, default: -> { false }

          key_value do
            map "initials", to: :initials
            map "givenNameFirst", to: :given_name_first
          end
        end
      end
    end
  end
end
