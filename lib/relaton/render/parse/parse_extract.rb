module Relaton
  module Render
    class Parse
      def host(doc)
        doc.relation.detect { |r| r.type == "includedIn" }&.bibitem
      end

      def title(doc)
        return nil if doc.nil?

        doc.title.first.title.content
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
        doc.edition || host&.edition
      end

      def place(doc, host)
        x = doc.place
        x.empty? && host and x = host.place
        x.empty? and return x
        x.map(&:name)
      end

      def publisher(doc, host)
        x = pick_contributor(doc, "publisher")
        host and x ||= pick_contributor(host, "publisher")
        x.nil? and return nil
        x.map { |c| extractname(c) }
      end

      def distributor(doc, host)
        x = pick_contributor(doc, "distributor")
        host and x ||= pick_contributor(host, "distributor")
        x.nil? and return nil
        x.map { |c| extractname(c) }
      end

      def series(doc)
        doc.series.detect { |s| s.type == "main" } ||
          doc.series.detect { |s| s.type.nil? } ||
          doc.series.first
      end

      def series_title(doc)
        doc.title&.title&.content || doc.formattedref
      end

      def series_abbr(doc)
        doc.abbreviation
      end

      def series_num(doc)
        doc.number
      end

      def series_partnumber(doc)
        doc.partnumber
      end

      def series_run(doc)
        doc.run
      end

      def standardidentifier(doc)
        doc.docidentifier.each_with_object([]) do |id, ret|
          ret << id.id unless %w(metanorma metanorma-ordinal).include? id.type
        end
      end

      def uri(doc)
        uri = nil
        %i(doi uri src).each do |t|
          uri = doc.link.detect { |u| u.type == t } and break
        end
        uri ||= doc.link.first
        return nil unless uri

        uri.content.to_s
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
        dr = doc.status&.stage&.value || host&.status&.stage&.value

        { iteration: iter_ordinal(doc) || iter_ordinal(host), status: dr }
      end

      def iter_ordinal(doc)
        return nil unless iter = doc&.status&.detect(&:iteration)

        iter
        # iter.to_i.localize.to_rbnf_s("SpelloutRules",
        #                             "spellout-ordinal").capitalize
      end

      def status(doc)
        doc.status&.stage&.value
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
        when RelatonBib::LocalizedString
          str.content
        when String
          str
        end
      end
    end
  end
end
