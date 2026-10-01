# frozen_string_literal: true

module Relaton
  module Render
    module Iso690
      # Public API: relaton model in, citation string out. The style
      # instance supplies every rendering decision; this class only wires
      # the template evaluator to the field resolver. No XML, no
      # intermediate hashes.
      class Renderer
        class Unrenderable < StandardError; end

        DEFAULT_STYLE = "author-date"

        class << self
          def render(model, style: DEFAULT_STYLE, lang: "en", script: "Latn")
            new(style: style, lang: lang, script: script).render(model)
          end

          def citation(model, disambiguator: nil, style: DEFAULT_STYLE,
                       lang: "en", script: "Latn")
            new(style: style, lang: lang, script: script)
              .citation(model, disambiguator: disambiguator)
          end
        end

        def initialize(style: DEFAULT_STYLE, lang: "en", script: "Latn")
          @style = Style.load(style)
          @i18n = I18n.load(lang).overlay!(@style.scheme.locale)
          @script = script
        end

        def render(model)
          out = Template.new(@style.template_for(Kinds.kind_for(model.type))).evaluate(
            Fields.new(model, style: @style, i18n: @i18n).to_h,
          )
          raise Unrenderable, "no renderable elements" if out.strip.empty?

          out
        end

        # In-text form: SURNAME, year + disambiguator (name-and-date)
        def citation(model, disambiguator: nil)
          Template.new(@style.templates.citation).evaluate(
            Fields.new(model, style: @style, i18n: @i18n,
                       disambiguator: disambiguator).to_h,
          )
        end
      end
    end
  end
end
