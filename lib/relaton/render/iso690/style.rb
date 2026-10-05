# frozen_string_literal: true

require "lutaml/model"

module Relaton
  module Render
    module Iso690
      # A citation style as an instance of the relaton-models CitationStyle
      # model: the citation scheme (name form, localized strings), the
      # citation and reference templates, and per-type template variants.
      # All rendering knowledge is data; the engine holds no styles, no
      # vocabularies, no localized strings.
      class Style < Lutaml::Model::Serializable
        autoload :NameForm, "relaton/render/iso690/style/name_form"
        autoload :Locale, "relaton/render/iso690/style/locale"
        autoload :Scheme, "relaton/render/iso690/style/scheme"
        autoload :TemplateMap, "relaton/render/iso690/style/template_map"
        autoload :SortRule, "relaton/render/iso690/style/sort_rule"
        autoload :TypeTemplate, "relaton/render/iso690/style/type_template"

        attribute :name, :string
        attribute :scheme, Scheme, default: -> { Scheme.new }
        attribute :templates, TemplateMap, default: -> { TemplateMap.new }
        attribute :per_type, TypeTemplate, collection: true, default: []
        attribute :sort_key, SortRule, collection: true, default: []

        key_value do
          map "name", to: :name
          map "scheme", to: :scheme
          map "templates", to: :templates
          map "perType", to: :per_type
          map "sortKey", to: :sort_key
        end

        # The index sort rules; creator then date when the style declares
        # none (the name-and-date default).
        def sort_keys
          return sort_key unless sort_key.empty?

          [SortRule.new(attribute: "creator"), SortRule.new(attribute: "date")]
        end

        # Per-type template selection is a data lookup; unmatched types
        # fall back to the general reference template. When a kind has
        # home-flagged variants, the split is resolved by whether the item
        # carries the scheme's home document identifier.
        def template_for(type, home: nil)
          candidates = per_type.select { |t| t.type == type.to_s }
          if candidates.size > 1 && !home.nil?
            candidates = candidates.select { |t| (t.home || false) == home }
          end
          candidates.first&.template || templates.reference
        end

        def title_form_for(type)
          per_type.lazy.select { |t| t.type == type.to_s }
            .find { |t| t.title && !t.title.empty? }&.title
        end

        # First-creator name form: the style's declared name template with
        # the surname upcased, per the name-and-date convention.
        def render_name(surname:, given:)
          Template.new(templates.name).evaluate(
            "surname" => Template::Field[!surname.empty?, surname.upcase],
            "givennames" => Template::Field[!given.empty?, given],
          )
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
