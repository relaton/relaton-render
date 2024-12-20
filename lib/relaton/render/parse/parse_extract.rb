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

      def localized_string_or_text(str)
        case str
        when RelatonBib::LocalizedString then content(str)
        when String then str
        end
      end

      def extent(doc)
        doc.extent.each_with_object([]) do |e, acc|
          case e
          when RelatonBib::Extent, RelatonBib::LocalityStack
            a = e.locality.each_with_object([]) do |e1, m|
              if e1.is_a?(RelatonBib::LocalityStack)
                m << extent1(e1.locality)
              else
                m.empty? and m << {}
                m[-1].merge!(extent1(Array(e1)))
              end
            end
            acc << a
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
        iter = doc&.status&.iteration or return nil
        iter
      end

      def status(doc)
        v = doc&.status&.stage&.value
        @i18n.get.dig("stage", v) || v
      end
    end
  end
end
