module Relaton
  module Render
    class Citations
      def initialize(opt = {})
        @type = opt[:type]
        @i18n = opt[:i18n]
        @renderer = opt[:renderer]
      end

      # takes array of { id, type, author, date, ord, data_liquid }
      def render(ret)
        cites = citations(ret)
        cites.each_key do |k|
          cites[k] = render1(cites[k])
        end
        cites
      end

      def render1(cit)
        r = @renderer.renderer(cit[:type] || "misc")
        cit[:formattedref] =
          @renderer.valid_parse(@i18n.l10n(r.render(cit[:data_liquid])))
        %i(type data_liquid).each { |x| cit.delete(x) }
        cit
      end

      def citations(ret)
        case @type
        when "author-date" then disambig_author_date_citations(ret)
        when nil then generic_citation(ret)
        else raise "Unimplemented citation type"
        end
      end

      def generic_citation(ret)
        ret.each_with_object({}) do |b, m|
          m[b[:id]] = { data_liquid: b[:data_liquid], type: b[:type],
                        citation: b[:data_liquid][:docidentifier] }
        end
      end

      # takes array of { id, type, author, date, ord, data_liquid }
      def disambig_author_date_citations(ret)
        to_hash(suffix_date(sort_ord(breakdown(ret))))
      end

      def breakdown(ret)
        ret.each_with_object({}) do |b, m|
          m[b[:author]] ||= {}
          m[b[:author]][b[:date]] ||= []
          m[b[:author]][b[:date]] << b
        end
      end

      def sort_ord(ret)
        ret.each do |author, v|
          v.each_key do |date|
            ret[author][date].sort! { |a, b| a[:ord] <=> b[:ord] }
          end
        end
      end

      def suffix_date(ret)
        ret.each_value do |v|
          v.each_value do |v1|
            next if v1.size < 2

            v1.each_with_index do |b, i|
              b[:date] += ("a".ord + i).chr.to_s
              b[:data_liquid][:date] = b[:date]
            end
          end
        end
        ret
      end

      def to_hash(ret)
        ret.each_with_object({}) do |(_k, v), m|
          v.each do |_k1, v1|
            v1.each do |b|
              m[b[:id]] = { author: b[:author], date: b[:date],
                            citation: "#{b[:author]} #{b[:date]}",
                            data_liquid: b[:data_liquid], type: b[:type] }
            end
          end
        end
      end
    end
  end
end
