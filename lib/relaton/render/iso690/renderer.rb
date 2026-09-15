# frozen_string_literal: true

module Relaton
  module Render
    module Iso690
      # Public API: relaton model in, citation string out. No XML, no
      # intermediate hashes.
      class Renderer
        class Unrenderable < StandardError; end

        class << self
          def render(model, style: "author-date", lang: "en", script: "Latn")
            new(style: style, lang: lang, script: script).render(model)
          end

          def citation(model, style: "author-date", lang: "en", script: "Latn")
            new(style: style, lang: lang, script: script).citation(model)
          end
        end

        def initialize(style: "author-date", lang: "en", script: "Latn")
          @style = Style.load(style)
          @i18n = I18n.new(lang, script)
        end

        def render(model)
          kind = Kinds.resolve(model).new(model, style: @style, i18n: @i18n)
          out = kind.render
          raise Unrenderable, "no renderable elements" if out.to_s.strip.empty?

          out
        end

        # In-text form: SURNAME, year (author–date styles)
        def citation(model)
          creator = Elements.build(:creator, model, style: @style, i18n: @i18n)
          date = Elements.build(:date, model, style: @style, i18n: @i18n)
          [creator.in_text, date.render.to_s].reject(&:empty?).join(", ")
        end
      end
    end
  end
end
