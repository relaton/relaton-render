# frozen_string_literal: true

require "lutaml/model"

module Relaton
  module Render
    module Iso690
      # Language-specific labels and typographic punctuation, declared per
      # language in i18n/<lang>.yml. Adding a language adds a YAML
      # declaration — no code. A style instance's localized strings overlay
      # the language pack; language-varying intra-element punctuation
      # (e.g. French " : " production separator) is declared under
      # `punct:`.
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

        def punct_fetch(key, default)
          punct.fetch(key, default)
        end

        # Style-instance localized strings win over the language pack.
        def overlay!(locale)
          labels.merge!(locale.label_map)
          self
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
