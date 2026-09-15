# frozen_string_literal: true

require "lutaml/model"

module Relaton
  module Render
    module Iso690
      # A citation style as typed configuration: element punctuation,
      # title emphasis markers, joins. No Liquid documents.
      class Style < Lutaml::Model::Serializable
        attribute :punct_config, :hash, default: {}
        attribute :title_open, :string, default: "_"
        attribute :title_close, :string, default: "_"

        DEFAULT_PUNCT = {
          "creator_join" => ", ",
          "production_sep" => ": ",
          "identifier_join" => ". ",
          # element name => punctuation appended after a present element
          "creator" => ". ",
          "title" => ". ",
          "edition" => ". ",
          "medium" => ". ",
          "series" => ". ",
          "production" => ", ",
          "date" => ". ",
          "numeration" => ". ",
          "component_part" => ". ",
          "identifier" => ". ",
          "location" => ". ",
        }.freeze

        key_value do
          map "punct", to: :punct_config
          map "title_open", to: :title_open
          map "title_close", to: :title_close
        end

        def punct(key)
          punct_config[key] || DEFAULT_PUNCT[key] || " "
        end

        class << self
          def load(name_or_path)
            path = style_path(name_or_path) or
              raise ArgumentError, "unknown style #{name_or_path}"
            from_yaml(File.read(path))
          end

          private

          def style_path(name)
            file = File.join(__dir__, "styles", "#{name}.yml")
            return file if File.file?(file)

            name if name.is_a?(String) && File.file?(name)
          end
        end
      end
    end
  end
end
