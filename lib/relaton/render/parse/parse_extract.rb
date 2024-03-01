module Relaton
  module Render
    class Parse
      def host(doc)
        doc.relation.detect { |r| r.type == "includedIn" }&.bibitem
      end

      # TODO : first is naive choice
      def title(doc)
        doc.nil? || doc.title.empty? and return nil
        t = doc.title.select { |x| x.title.language&.include? @lang }
        t.empty? and t = doc.title
        t1 = t.select { |x| x.type == "main" }
        t1.empty? and t1 = t
        content(t1.first&.title)
      end

      def medium(doc, host)
        x = doc.medium || host&.medium or return nil
        %w(content genre form carrier size scale).each_with_object({}) do |i, m|
          m[i] = x.send i
        end.compact
      end

      def size(doc)
        x = doc.size or return nil
        x.size.each_with_object({}) do |v, m|
          m[v.type] ||= []
          m[v.type] << v.value
        end
      end

      def edition(doc, host)
        content(doc.edition || host&.edition)
      end

      def edition_num(doc, host)
        doc.edition&.number || host&.edition&.number
      end

      def place(doc, host)
        x = doc.place
        x.empty? && host and x = host.place
        x.empty? and return x
        x.map { |p| place1(p) }
      end

      def place1(place)
        c = place.city
        r = place.region
        n = place.country
        c.nil? && r.empty? && n.empty? and return place.name
        ret = [c] + r.map(&:name) + n.map(&:name)
        @i18n.l10n(ret.compact.join(", "))
      end

      def series(doc)
        doc.series.detect { |s| s.type == "main" } ||
          doc.series.detect { |s| s.type.nil? } ||
          doc.series.first
      end

      def series_title(series, _doc)
        series.nil? and return nil
        series.title.respond_to?(:titles) && !series.title.titles.empty? and
          return content(series.title.titles.first.title)
        series.title.respond_to?(:title) and
          return content(series.title.title)
        series.title.respond_to?(:formattedref) and
          content(series.formattedref)
      end

      def series_formatted(series, _doc)
        content(series.formattedref)
      end

      def series_abbr(series, _doc)
        content(series.abbreviation)
      end

      def series_num(series, _doc)
        series.number
      end

      def series_partnumber(series, _doc)
        series.partnumber
      end

      def series_run(series, _doc)
        series.run
      end

      def series_org(series, _doc)
        series.organization
      end

      def series_place(series, _doc)
        series.place
      end

      def series_dates(series, _doc)
        f = series.from
        t = series.to
        f || t or return nil
        "#{f}–#{t}"
      end

      def auth_id_filter(ids)
        ids.detect { |i| i.type == "IEEE" && i.scope == "trademark" } &&
          ids.detect { |i| i.type == "IEEE" && i.scope != "trademark" } and
          ids.reject! { |i| i.type == "IEEE" && i.scope != "trademark" }
        ids
      end

      def authoritative_identifier(doc)
        out = auth_id_filter(doc.docidentifier).each_with_object([]) do |id, m|
          id.primary && !authoritative_identifier_exclude.include?(id.type) and
            m << id.id
        end
        out.empty? and out = doc.docidentifier.each_with_object([]) do |id, m|
          authoritative_identifier_exclude.include?(id_type_norm(id)) or
            m << id.id
        end
        out
      end

      def authoritative_identifier_exclude
        %w(metanorma metanorma-ordinal) + other_identifier_include
      end

      def other_identifier(doc)
        doc.docidentifier.each_with_object([]) do |id, ret|
          type = id_type_norm(id)
          other_identifier_include.include? type or next
          ret << @i18n.l10n("#{type}: #{id.id}")
        end
      end

      def other_identifier_include
        %w(ISSN ISBN DOI)
      end

      def doi(doc)
        out = doc.docidentifier.each_with_object([]) do |id, ret|
          type = id.type&.sub(/^(DOI)\..*$/i, "\\1") or next
          type.casecmp("doi").zero? or next
          ret << id.id
        end
        out.empty? ? nil : out
      end

      def id_type_norm(id)
        id.type&.sub(/^(ISBN|ISSN)\..*$/i) { $1.upcase }
      end

      def uri(doc)
        uri = nil
        %w(citation uri src).each do |t|
          uri = uri_type_select(doc, t) and break
        end
        uri ||= doc.link.detect do |u|
          u.language == @lang && !u.type&.casecmp("doi")&.zero?
        end
        uri ||= doc.link.detect { |u| !u.type&.casecmp("doi")&.zero? }
        uri or return nil
        uri.content.to_s.strip
      end

      def uri_type_select(doc, type)
        uri = doc.link.detect do |u|
          u.type&.downcase == type && u.language == @lang
        end and return uri
        uri = doc.link.detect { |u| u.type&.downcase == type } and return uri
        nil
      end

      def access_location(doc, host)
        x = doc.accesslocation || host&.accesslocation or
          return nil
        x.first
      end

      def included(type)
        ["article", "inbook", "incollection", "inproceedings"].include? type
      end

      def type(doc)
        type = doc.type and return type
        doc.relation.any? { |r| r.type == "includedIn" } and return "inbook"
        "book"
      end

      def extent1(localities)
        localities.each_with_object({}) do |l, ret|
          ret[(l.type || "page").to_sym] = {
            from: localized_string_or_text(l.reference_from),
            to: localized_string_or_text(l.reference_to),
          }
        end
      end

      def extent(doc)
        doc.extent.each_with_object([]) do |e, acc|
          case e
          when RelatonBib::LocalityStack
            acc << extent1(e.locality)
          when RelatonBib::Locality
            acc << extent1(Array(e))
          end
        end
      end

      def draft(doc, host)
        { iteration: iter_ordinal(doc) || iter_ordinal(host),
          status: status(doc) || status(host) }
      end

      def iter_ordinal(doc)
        return nil unless iter = doc&.status&.iteration

        iter
      end

      def status(doc)
        doc&.status&.stage&.value
      end

      private

      def blank?(text)
        text.nil? || text.empty?
      end

      def pick_contributor(doc, role)
        ret = doc.contributor.select do |c|
          c.role.any? { |r| r.type == role }
        end
        ret.empty? ? nil : ret
      end

      def localized_string_or_text(str)
        case str
        when RelatonBib::LocalizedString then content(str)
        when String then str
        end
      end
    end
  end
end
