# frozen_string_literal: true

module Relaton
  module Render
    module Iso690
      class Style
        # TypeTemplate: the template variant for one bibliographic item
        # type, selected by data lookup (relaton-models TypeTemplate).
        class TypeTemplate < Lutaml::Model::Serializable
          attribute :type, :string
          attribute :template, :string

          key_value do
            map "type", to: :type
            map "template", to: :template
          end
        end
      end
    end
  end
end
