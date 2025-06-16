module Relaton
  module Render
    class Parse
      def content(node)
        node.nil? and return node
        node.content.is_a?(Array) and return node.content.map { |x| content(x) }
        node.content.strip
          .gsub("</title>", "").gsub("<title>", "")
        # node.children.map { |n| n.text? ? n.content : n.to_xml }.join
        # node.text? ? node.content.strip : node.to_xml.strip
      end

      def extract_orgname(org)
        content(org.name&.first)
      end

      def extract_personname(person)
        surname = person.name.surname || person.name.completename
        given, middle, initials = given_and_middle_name(person)
        { surname: content(surname),
          given: given,
          middle: middle,
          initials: initials }
      end

      def given_and_middle_name(person)
        forenames = forenames_parse(person)
        initials = extract_initials(person)
        forenames.empty? and initials.empty? and return [nil, nil, nil]
        initials.empty? and initials = initials_from_forenames(forenames)
        [forenames.first, forenames[1..-1], Array(initials)]
      end

      def extract_initials(person)
        initials = content(person.name.initials)&.sub(/(.)\.?$/, "\\1.")
          &.split /(?<=\.) /
        initials ||= person.name.forename.map(&:initial)
          .compact.map { |x| x.sub(/(.)\.?$/, "\\1.") }
        initials
      end

      def forenames_parse(person)
        person.name.forename.map do |x|
          x.content.empty? ? "#{x.initial}." : content(x)
        end
      end

      # de S. => one initial, M.-J. => one initial
      def initials_parse(person)
        i = content(person.name.initials) or
          return person.name.forename.map(&:initial)
              .compact.map { |x| x.sub(/(.)\.?$/, "\\1.") }

        i.sub(/(.)\.?$/, "\\1.")
          .scan(/.+?\.(?=(?:$|\s|\p{Alpha}))/).map(&:strip)
      end

      def initials_from_forenames(forenames)
        forenames.map(&:split).flatten.map { |x| "#{x[0]}." }
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
        contributors.length.positive? or return nil
        desc = contributors[0].role.first.description.join("\n")
        type = contributors[0].role.first.type
        desc.empty? ? type : desc
      end

      def creatornames(doc)
        cr = creatornames1(doc)
        cr.empty? and return [nil, nil]
        [cr.map { |x| extractname(x) }, contributor_role(cr)]
      end

      def creatornames_roles_allowed
        %w(author performer adapter translator editor distributor authorizer)
      end

      def creatornames1(doc)
        cr = []
        doc.nil? and return []
        creatornames_roles_allowed.each do |r|
          add = pick_contributor(doc, r)
          add.nil? and next
          cr = add and break
        end
        cr.nil? and cr = doc.contributor
        cr
      end

      def datepick(date)
        date.nil? and return nil
        on = date.on
        from = date.from
        to = date.to
        on and return { on: on }
        from and return { from: from, to: to }
        nil
      end

      def date1(date)
        %w(published issued circulated).each do |t|
          ret = date.detect { |x| x.type == t } and
            return ret
        end
        date.reject { |x| x.type == "accessed" }.first
      end

      # year-only
      def date(doc, host)
        ret = date1(doc.date)
        host and ret ||= date1(host.date)
        datepick(ret)&.transform_values do |v|
          v&.sub(/-.*$/, "")
        end
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

      def publisher(doc, host)
        x = pick_contributor(doc, "publisher")
        host and x ||= pick_contributor(host, "publisher")
        x.nil? and return nil
        x.map { |c| extractname(c) }
      end

      def publisher_abbrev(doc, host)
        x = pick_contributor(doc, "publisher")
        host and x ||= pick_contributor(host, "publisher")
        x.nil? and return nil
        x.map do |c|
          content(c.entity.abbreviation) ||
            content(c.entity.name.first)
        end
      end

      def distributor(doc, host)
        x = pick_contributor(doc, "distributor")
        host and x ||= pick_contributor(host, "distributor")
        x.nil? and return nil
        x.map { |c| extractname(c) }
      end

      def authorizer(doc, host)
        x = pick_contributor(doc, "authorizer") ||
          pick_contributor(doc, "publisher")
        host and x ||= pick_contributor(host, "authorizer") ||
          pick_contributor(host, "publisher")
        x.nil? and return nil
        x.map { |c| extractname(c) }
      end

      def pick_contributor(doc, role)
        ret = doc.contributor.select do |c|
          c.role.any? { |r| r.type == role }
        end
        ret.empty? ? nil : ret
      end
    end
  end
end
