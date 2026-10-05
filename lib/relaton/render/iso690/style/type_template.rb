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
          # The short-cite template for this kind; absent falls back to
          # the reference template in short mode
          attribute :short, :string
          # Render the style's no_place label when the publisher has no
          # place (the book-family templates of some flavors)
          attribute :no_place, :boolean

          key_value do
            map "type", to: :type
            map "template", to: :template
            map "series", to: :series
            map "title", to: :title
            map "home", to: :home
            map "fallbacks", to: :fallbacks
            map "short", to: :short
            map "noPlace", to: :no_place
          end
        end
      end
    end
  end
end
