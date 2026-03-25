module Relaton
  module Render
    class Parse
      def host(doc)
        doc.relation&.detect { |r| r.type == "includedIn" }&.bibitem
      end

      # TODO : first is naive choice
      def title(doc)
        doc.nil? || doc.title.nil? || doc.title.empty? and return nil
        t = Array(doc.title).select { |x| x.language == @lang }
        t.empty? and t = Array(doc.title)
        t1 = t.select { |x| x.type == "main" }
        t1.empty? and t1 = t
        t1.first or return
        esc(content(t1.first))
      end

      def medium(doc, host)
        x = doc.medium || host&.medium or return nil
        %w(content genre form carrier size scale).each_with_object({}) do |i, m|
          m[i] = x.send i
        end.compact
      end

      def size(doc)
        x = doc.size or return nil
        x.value.each_with_object({}) do |v, m|
          m[v.type] ||= []
          m[v.type] << v.content
        end
      end

      def edition(doc, host)
        ret = content(doc.edition || host&.edition)
        ret &&= esc(ret)
        ret
      end

      def edition_num(doc, host)
        doc.edition&.number || host&.edition&.number
      end

      def place(doc, host)
        x = Array(doc.place)
        x.empty? && host and x = Array(host.place)
        x.empty? and return x
        x.map { |p| place1(p) }
      end

      def place1(place)
        c = place.city
        r = place.region
        n = place.country
        c.nil? && r.empty? && n.empty? and return place.formatted_place
        [c, *r.map(&:content), *n.map(&:content)].compact.join(", ")
      end

      def series(doc)
        doc.series&.detect { |s| s.type == "main" } ||
          doc.series&.detect { |s| s.type.nil? } ||
          doc.series&.first
      end

      def series_title(series, _doc)
        series.nil? and return nil
        t = Array(series.title).select { |x| x.language == @lang }
        t.empty? and t = Array(series.title)
        t1 = t.select { |x| x.type == "main" }
        t1.empty? and t1 = t
        t1.first.nil? and return nil
        content(t1.first)
      end

      def series_formatted(series, _doc)
        content(series.formattedref)
      end

      def series_abbr(series, _doc)
        content(series.abbreviation)
      end

      def series_num(series, _doc)
        series.number&.strip
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
        p = series.place or return nil
        place1(p)
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
        Array(x).first
      end

      def included(type)
        ["article", "inbook", "incollection", "inproceedings"].include? type
      end

      def type(doc)
        type = doc.type and return type
        doc.relation&.any? { |r| r.type == "includedIn" } and return "inbook"
        "book"
      end

      def language(doc)
        doc.language&.first || @lang
      end

      def script(doc)
        doc.script&.first || @script
      end

      def locale(doc)
        # TODO not yet implemented in relaton-bib
        # doc.locale&.first
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
        when Relaton::Bib::LocalizedString then content(str)
        when String then str
        end
      end

      def extent(doc)
        Array(doc.extent).each_with_object([]) do |e, acc|
          case e
          when Relaton::Bib::Extent, Relaton::Bib::LocalityStack
            if e.locality.any?
              a = e.locality.each_with_object([]) do |e1, m|
                if e1.is_a?(Relaton::Bib::LocalityStack)
                  m << extent1(e1.locality)
                else
                  m.empty? and m << {}
                  m[-1].merge!(extent1(Array(e1)))
                end
              end
              acc << a
            else
              Array(e.locality_stack).each do |stack|
                a = stack.locality.each_with_object([{}]) do |e1, m|
                  m[-1].merge!(extent1(Array(e1)))
                end
                acc << a
              end
            end
          when Relaton::Bib::Locality
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
        v = doc&.status&.stage&.content
        #@i18n.get.dig("stage", v) || v
      end
    end
  end
end
