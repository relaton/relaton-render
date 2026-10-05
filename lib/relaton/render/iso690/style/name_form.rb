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
          # Where an all-editor creator list's role marker sits relative
          # to the name's terminating period: "glue" renders
          # "NAME (eds.)." (the name-date default), "afterPeriod"
          # renders "NAME. (eds.)" (ISO 690 clause-flavour).
          attribute :role_placement, :string, default: "glue"
          # A completename is rendered, not decomposed; styles that
          # upcase inverted names may declare the completename treatment
          attribute :completename_upcase, :boolean, default: -> { false }

          key_value do
            map "initials", to: :initials
            map "givenNameFirst", to: :given_name_first
            map "rolePlacement", to: :role_placement
            map "completenameUpcase", to: :completename_upcase
          end
        end
      end
    end
  end
end
