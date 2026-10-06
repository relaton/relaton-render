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
            !creators.empty? || !fallback_name.empty?
          end

          def render
            return plain_render if @short

            joined = if creators.empty?
                       fallback_name
                     elsif (form = @style.templates.creators) && !form.empty?
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
              # template; a lone editor is unmarked unless declared
              if editors? && marked?
                "#{period(joined)} (#{role_word}) "
              else
                "#{period(joined)} "
              end
            else
              marker = editors? && marked? ? " (#{role_word})" : ''
              "#{joined}#{marker}"
            end
          end

          # The short cite splits after the creators: they render as a
          # plain join, without the wrap and sentence period (1.x
          # short-cite templates carried no wrap)
          def plain_render
            marker = editors? && creators.size > 1 ? " (#{role_word})" : ''
            "#{join(names)}#{marker}"
          end

          def role_placement
            @style.scheme.name_form.role_placement || "glue"
          end

          def period(text)
            text.end_with?(".") ? text : "#{text}."
          end

          def marked?
            creators.size > 1 || name_form.lone_editor_marked
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

          # The declared creator fallback for items with no personal
          # creators: the publisher's abbreviation or full name
          def fallback_name
            orgs = contributors("publisher")
            name = case name_form.creator_fallback
                   when "publisher_abbrev"
                     orgs.map do |c|
                       localized(c.organization&.abbreviation)
                     end
                   when "publisher_name"
                     orgs.map do |c|
                       localized(Array(c.organization&.name).first)
                     end
                   else
                     []
                   end
            name.reject(&:empty?).first.to_s
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
            join_names(names)
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
