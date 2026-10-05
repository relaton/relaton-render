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
          attribute :series, :string
          attribute :title, :string
          attribute :home, :boolean
          attribute :fallbacks, :hash, default: -> { {} }

          key_value do
            map "type", to: :type
            map "template", to: :template
            map "series", to: :series
            map "title", to: :title
            map "home", to: :home
            map "fallbacks", to: :fallbacks
          end
        end
      end
    end
  end
end
