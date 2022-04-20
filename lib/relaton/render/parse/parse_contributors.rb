module Relaton
  module Render
    class Parse
      def extract_orgname(org)
        org.name&.first&.content
      end

      def extract_personname(person)
        surname = person.name.surname || person.name.completename
        given, middle, initials = given_and_middle_name(person)
        { surname: surname.content,
          given: given,
          middle: middle,
          initials: initials }
      end

      def given_and_middle_name(person)
        forenames = person.name.forename.map(&:content)
        initials = person.name.initial.map(&:content)
          .map { |x| x.sub(/\.$/, "") }
        forenames.empty? and initials.empty? and return [nil, nil, nil]
        initials.empty? and initials = forenames.map { |x| x[0] }
        [forenames.first, forenames[1..-1], initials]
      end

      def extractname(contributor)
        org = contributor.entity if contributor.entity
          .is_a?(RelatonBib::Organization)
        person = contributor.entity if contributor.entity
          .is_a?(RelatonBib::Person)
        return { nonpersonal: extract_orgname(org) } if org
        return extract_personname(person) if person

        nil
      end

      def contributor_role(contributors)
        return nil unless contributors.length.positive?

        desc = contributors[0].role.first.description.join("\n")
        type = contributors[0].role.first.type
        desc.empty? ? type : desc
      end

      def creatornames(doc)
        cr = creatornames1(doc)
        cr.empty? and return [nil, nil]
        [cr.map { |x| extractname(x) }, contributor_role(cr)]
      end

      def creatornames1(doc)
        cr = []
        return [] if doc.nil?

        %w(author performer adapter translator editor publisher distributor)
          .each do |r|
            add = pick_contributor(doc, r)
            next if add.nil?

            cr = add and break
          end
        cr.nil? and cr = doc.contributor
        cr
      end

      def datepick(date)
        return nil if date.nil?

        on = date.on
        from = date.from
        to = date.to
        return { on: on } if on
        return { from: from, to: to } if from

        nil
      end

      def date1(date)
        %w(published issued circulated).each do |t|
          ret = date.detect { |x| x.type == t } and
            return ret
        end
        date.first
      end

      def date(doc, host)
        ret = date1(doc.date)
        host and ret ||= date1(host.date)
        datepick(ret)
      end

      def date_updated(doc, host)
        ret = doc.date.detect { |x| x.type == "updated" }
        host and ret ||= host.date.detect { |x| x.type == "updated" }
        datepick(ret)
      end

      def date_accessed(doc, host)
        ret = doc.date.detect { |x| x.type == "accessed" }
        host and ret ||= host.date.detect { |x| x.type == "accessed" }
        datepick(ret)
      end
    end
  end
end
