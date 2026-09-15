# frozen_string_literal: true

module Relaton
  module Render
    module Iso690
      module Elements
        # Name(s) of creator(s) (ISO 690 clause 7.2). The first creator is
        # given inverted (SURNAME, forenames), subsequent creators in
        # direct order (forenames SURNAME); name parts come from the typed
        # model, never decomposed from a rendered string.
        class Creator < Element
          def present?
            !creators.empty?
          end

          def render
            "#{join(names)}#{role_suffix}"
          end

          # In-text (author–date) form: the principal creator only
          def in_text
            principal = creators.first or return ""
            person = principal.person or return org_name(principal)
            completename(person) || surname(person)&.upcase || ""
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
              (first ? inverted(person) : direct(person))
            name.empty? ? org_name(contributor) : name
          end

          def inverted(person)
            [surname(person)&.upcase, forenames(person)]
              .reject(&:empty?).join(", ")
          end

          def direct(person)
            [forenames(person), surname(person)&.upcase]
              .reject(&:empty?).join(" ")
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

          def role_suffix
            return "" unless editors?

            suffix = creators.one? ? @i18n.label("ed") : @i18n.label("eds")
            " (#{suffix})"
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

          def forenames(person)
            Array(person.name&.forename).map { |f| localized(f) }
              .reject(&:empty?).join(" ")
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
