# frozen_string_literal: true

module Relaton
  module Render
    module Iso690
      # Base data element (ISO 690 clause 7). An element wraps typed data
      # taken from the relaton model instance; #present? is the omission
      # predicate, #render the element's formatting method. Punctuation
      # between elements belongs to the kind/style, not the element.
      class Element
        def initialize(model, style:, i18n:, kind: nil)
          @model = model
          @style = style
          @i18n = i18n
          @kind = kind
        end

        def present?
          false
        end

        def render
          nil
        end

        private

        def localized(value)
          value&.content.to_s
        end

        # Localizable values scoped to the render language: the variants
        # declared in that language, or all of them when none matches
        def titles_in_lang(values)
          titles = Array(values)
          in_lang = titles.select { |t| Array(t.language).include?(@i18n.lang) }
          in_lang.empty? ? titles : in_lang
        end

        def contributors(role)
          Array(@model.contributor).select { |c| has_role?(c, role) }
        end

        def has_role?(contributor, role)
          Array(contributor.role).any? do |r|
            r.is_a?(String) ? r == role : r.type == role
          end
        end

        def org_name(contributor)
          name = Array(contributor.organization&.name)
            .map { |n| localized(n).upcase }.join(", ")
          abbrev = localized(contributor.organization&.abbreviation)
          return name if name.empty? || abbrev.empty?

          "#{name} (#{abbrev})"
        end

        def item_kind
          @kind || Kinds.kind_for(@model.type)
        end

        def person_completename(person)
          localized(person.name&.completename)
        end

        def person_surname(person)
          localized(person.name&.surname)
        end

        def person_given(person)
          parts = Array(person.name&.forename).map do |f|
            content = localized(f)
            next content unless content.empty?
            next "#{f.initial}." if f.initial.to_s.length == 1

            ""
          end.reject(&:empty?)
          return localized(person.name&.formatted_initials) if parts.empty?
          return parts.map { |p| "#{p[0]}." }.join(" ") if initials?

          parts.join(" ")
        end

        def initials?
          @style.scheme.name_form.initials
        end

        def join_names(names)
          case names.size
          when 0 then ""
          when 1 then names.first
          when 2 then names.join(" #{@i18n.label('and')} ")
          else
            "#{names[0..-2].join(', ')}#{@i18n.label('oxford_comma')} " \
            "#{@i18n.label('and')} #{names.last}"
          end
        end
      end
    end
  end
end
