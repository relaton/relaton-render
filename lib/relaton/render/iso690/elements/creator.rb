# frozen_string_literal: true

module Relaton
  module Render
    module Iso690
      module Elements
        # Name(s) of creator(s) (ISO 690 clause 7.2). The first creator is
        # given inverted per the style's name form (SURNAME, forenames),
        # subsequent creators in direct order (forenames SURNAME); name
        # parts come from the typed model, never decomposed from a
        # rendered string.
        class Creator < Element
          def present?
            !creators.empty?
          end

          def render
            case role_placement
            when "afterPeriod"
              # the in-slot trailing space separates the (ed.) marker from
              # the next element, which follows directly in the template
              editors? ? "#{join(names)}. (#{role_word}) " : "#{join(names)}. "
            else
              "#{join(names)}#{editors? ? " (#{role_word})" : ''}"
            end
          end

          def role_placement
            @style.scheme.name_form.role_placement || "glue"
          end

          def role_word
            @i18n.label(creators.one? ? "ed" : "eds")
          end

          # In-text (name-and-date) form: the principal creator only
          def in_text
            principal = creators.first or return ""
            person = principal.person or return org_name(principal)
            completename(person) || surname(person)&.upcase || ""
          end

          # The principal creator's given names, as the name form declares
          def principal_given
            principal = creators.first or return ""
            person = principal.person or return ""
            complete = completename(person)
            return "" if complete

            given_names(person)
          end

          private

          def creators
            @creators ||= begin
              found = contributors("author")
              found = contributors("editor") if found.empty?
              found
            end
          end

          def names
            creators.each_with_index
              .map do |contributor, index|
              format(contributor,
                     first: index.zero?)
            end
          end

          def format(contributor, first:)
            person = contributor.person or return org_name(contributor)
            name = completename(person) ||
              personal_name(person, first: first)
            name.empty? ? org_name(contributor) : name
          end

          def personal_name(person, first:)
            surname = surname(person).to_s
            given = given_names(person)
            if first && !name_form.given_name_first
              @style.render_name(surname: surname, given: given)
            else
              [given, surname.upcase].reject(&:empty?).join(" ")
            end
          end

          def name_form
            @style.scheme.name_form
          end

          def join(names)
            case names.size
            when 0 then ""
            when 1 then names.first
            when 2 then names.join(" #{@i18n.label('and')} ")
            else
              "#{names[0..-2].join(', ')}#{@i18n.label('oxford_comma')} " \
              "#{@i18n.label('and')} #{names.last}"
            end
          end

          def editors?
            !creators.empty? && creators.all? { |c| has_role?(c, "editor") }
          end

          def completename(person)
            value = localized(person.name&.completename)
            value.empty? ? nil : value
          end

          def surname(person)
            value = localized(person.name&.surname)
            value.empty? ? nil : value
          end

          def given_names(person)
            names = Array(person.name&.forename).map { |f| localized(f) }
              .reject(&:empty?)
            return names.map { |n| "#{n[0]}." }.join(" ") if name_form.initials

            names.join(" ")
          end

          def org_name(contributor)
            name = Array(contributor.organization&.name)
              .map { |n| localized(n).upcase }.join(", ")
            abbrev = localized(contributor.organization&.abbreviation)
            return name if name.empty? || abbrev.empty?

            "#{name} (#{abbrev})"
          end
        end
      end
    end
  end
end
