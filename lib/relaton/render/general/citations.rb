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
        cites.each_value do |v|
          v[:renderer] = @renderer.renderer(v[:type] || "misc")
        end
        enhance_data(cites)
        cites.each_key do |k|
          cites[k] = render1(cites[k])
        end
        cites
      end

      def enhance_data(cites)
        ret = extract_uris_for_lookup(cites)
        ret.empty? and return
        # functionality removed: date needs to be given explicitly
        # @renderer.urls_exist_concurrent(ret.keys).each do |k, v|
        # ret[k].each { |u| add_date_accessed(cites[u], k, v) }
        # end
      end

      def extract_uris_for_lookup(cites)
        cites.each_with_object({}) do |(k, v), m|
          u = extract_uri_for_lookup(v) or next
          m[u] ||= []
          m[u] << k
        end
      end

      def extract_uri_for_lookup(cite)
        t = cite[:renderer].template_raw
        c = cite[:data_liquid]
        t.is_a?(String) or return
        (/\{\{\s*date_accessed\s*\}\}/.match?(t) &&
        /\{\{\s*uri\s*\}\}/.match?(t) &&
        c[:uri_raw] && !c[:date_accessed]) or return
        c[:uri_raw]
      end

      def add_date_accessed(data, uri, status)
        if status
          data[:data_liquid][:date_accessed] = { on: ::Date.today.to_s }
          data[:data_liquid] = @renderer.fieldsklass.new(renderer: @renderer)
            .compound_fields_format(data[:data_liquid])
        else
          @renderer.url_warn(uri)
        end
      end

      def render1(cit)
        cit[:formattedref] =
          @renderer.valid_parse(
            @i18n.l10n(cit[:renderer].render(cit[:data_liquid])),
          )
        %i(type data_liquid renderer).each { |x| cit.delete(x) }
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
            ret[author][date].sort_by! { |a| a[:ord] }
          end
        end
      end

      def suffix_date(ret)
        ret.each do |k, v|
          v.each do |k1, v1|
            next if v1.reject { |b| b[:date].nil? }.size < 2

            suffix_date1(ret, k, k1)
          end
        end
        ret
      end

      def suffix_date1(ret, key1, key2)
        ret[key1][key2].each_with_index do |b, i|
          next if b[:date].nil?

          b[:date] += ("a".ord + i).chr.to_s
          b[:data_liquid][:date] = b[:date]
        end
      end

      def to_hash(ret)
        ret.each_with_object({}) do |(_k, v), m|
          v.each_value do |v1|
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
