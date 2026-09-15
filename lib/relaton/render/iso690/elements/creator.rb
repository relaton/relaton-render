# frozen_string_literal: true

module Relaton
  module Render
    module Iso690
      module Elements
        # Name(s) of creator(s) (ISO 690 clause 7.2): SURNAME, given names.
        # Name parts come from the typed model — never decomposed from a
        # rendered string.
        class Creator < Element
          def present?
            !creators.empty?
          end

          def render
            creators.map { |c| format(c) }
              .join(@style.punct("creator_join"))
          end

          # In-text (author–date) form: the principal creator only
          def in_text
            principal = creators.first or return ""
            person = principal.person or return org_name(principal)
            completename(person) || surname(person)&.upcase || ""
          end

          private

          def creators
            @creators ||= contributors("author")
          end

          def format(contributor)
            person = contributor.person or return org_name(contributor)
            name = completename(person) ||
              [surname(person)&.upcase, forenames(person)]
                .reject(&:empty?).join(", ")
            name.empty? ? org_name(contributor) : name
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
            Array(contributor.organization&.name).map { |n| localized(n) }
              .join(", ")
          end
        end
      end
    end
  end
end
