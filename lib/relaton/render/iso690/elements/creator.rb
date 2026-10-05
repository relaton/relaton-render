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
            joined = if (form = @style.templates.creators) && !form.empty?
                       ::Relaton::Render::Iso690::Template.new(form).evaluate(
                         "names" => Template::Field[true, join(names)],
                       )
                     else
                       join(names)
                     end
            case role_placement
            when "afterPeriod"
              # the in-slot trailing space separates the (eds.) marker
              # from the next element, which follows directly in the
              # template; a lone editor is unmarked
              if editors? && creators.size > 1
                "#{period(joined)} (#{role_word}) "
              else
                "#{period(joined)} "
              end
            else
              marker = editors? && creators.size > 1 ? " (#{role_word})" : ''
              "#{joined}#{marker}"
            end
          end

          def role_placement
            @style.scheme.name_form.role_placement || "glue"
          end

          def period(text)
            text.end_with?(".") ? text : "#{text}."
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
            name = completename_name(person, first: first) ||
              personal_name(person, first: first)
            name.empty? ? org_name(contributor) : name
          end

          def completename_name(person, first:)
            complete = completename(person) or return nil
            return complete unless name_form.completename_upcase

            first ? @style.render_name(surname: complete, given: "") :
              complete.upcase
          end

          def personal_name(person, first:)
            surname = surname(person).to_s
            given = given_names(person)
            if (first || name_form.inverted_all) && !name_form.given_name_first
              @style.render_name(surname: surname, given: given)
            else
              [given, surname.upcase].reject(&:empty?).join(" ")
            end
          end

          def name_form
            @style.scheme.name_form
          end

          def join(names)
            oxford = @i18n.label("oxford_comma")
            if serial_list? && names.size > 1 && !oxford.empty?
              return "#{names[0..-2].join(', ')}#{oxford} " \
                "#{@i18n.label('and')} #{names.last}"
            end

            join_names(names)
          end

          # Serial list style: every gap takes the serial form, even
          # between two names
          def serial_list?
            @style.scheme.name_form.list_style == "serial"
          end

          def editors?
            !creators.empty? && creators.all? { |c| has_role?(c, "editor") }
          end

          def completename(person)
            value = person_completename(person)
            value.empty? ? nil : value
          end

          def surname(person)
            value = person_surname(person)
            value.empty? ? nil : value
          end

          def given_names(person)
            person_given(person)
          end

          def org_name(contributor)
            super
          end
        end
      end
    end
  end
end
