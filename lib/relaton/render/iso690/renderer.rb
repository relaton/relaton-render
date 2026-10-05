# frozen_string_literal: true

module Relaton
  module Render
    module Iso690
      # Public API: relaton model in, citation string out. The style
      # instance supplies every rendering decision; this class only wires
      # the template evaluator to the field resolver. No XML, no
      # intermediate hashes.
      class Renderer
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

        def initialize(style: DEFAULT_STYLE, lang: "en", script: "Latn",
                       labels: {})
          @style = Style.load(style)
          @i18n = I18n.load(lang)
          @i18n.overlay_hash!(labels) unless labels.empty?
          # The style instance is the citation-style authority: its
          # declared strings win over the caller's generic i18n hash
          @i18n.overlay!(@style.scheme.locale)
          @script = script
        end

        def render(model)
          kind = Kinds.kind_for(model.type)
          template = @style.template_for(kind, home: home_docid?(model))
          out = Template.new(template).evaluate(
            Fields.new(model, style: @style, i18n: @i18n).to_h,
          )
          raise ::Relaton::Render::Unrenderable,
                "no renderable elements" if out.strip.empty?

          out
        end

        def home_docid?(model)
          types = Array(@style.scheme.home_docid_type)
          return false if types.empty?

          Array(model.docidentifier).any? { |d| types.include?(d.type) }
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
