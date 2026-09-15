# frozen_string_literal: true

require "lutaml/model"

module Relaton
  module Render
    module Iso690
      # Language-specific labels and typographic punctuation, declared per
      # language in i18n/<lang>.yml. Adding a language adds a YAML
      # declaration — no code. Language-varying element punctuation
      # (e.g. French " : " production separator) is declared under
      # `punct:` and overlaid onto the style by the renderer.
      class I18n < Lutaml::Model::Serializable
        attribute :lang, :string, default: "en"
        attribute :labels, :hash, default: {}
        attribute :punct, :hash, default: {}

        key_value do
          map "lang", to: :lang
          map "labels", to: :labels
          map "punct", to: :punct
        end

        def label(key)
          labels.fetch(key.to_s, key.to_s)
        end

        class << self
          def load(lang = "en")
            code = lang.to_s.empty? ? "en" : lang
            path = File.join(__dir__, "i18n", "#{code}.yml")
            unless File.file?(path)
              raise ArgumentError, "no i18n declarations for language #{code}"
            end

            from_yaml(File.read(path))
          end
        end
      end
    end
  end
end
