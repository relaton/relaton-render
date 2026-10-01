# frozen_string_literal: true

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
        autoload :TypeTemplate, "relaton/render/iso690/style/type_template"

        attribute :name, :string
        attribute :scheme, Scheme, default: -> { Scheme.new }
        attribute :templates, TemplateMap, default: -> { TemplateMap.new }
        attribute :per_type, TypeTemplate, collection: true, default: []

        key_value do
          map "name", to: :name
          map "scheme", to: :scheme
          map "templates", to: :templates
          map "perType", to: :per_type
        end

        # Per-type template selection is a data lookup; unmatched types
        # fall back to the general reference template.
        def template_for(type)
          per_type.find { |t| t.type == type.to_s }&.template ||
            templates.reference
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
