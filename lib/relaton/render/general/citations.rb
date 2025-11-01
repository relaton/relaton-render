module Relaton
  module Render
    class Citations
      def initialize(opt = {})
        # @type = opt[:type]
        @i18n = opt[:i18n]
        @lang = opt[:lang]
        @script = opt[:script]
        @renderer = opt[:renderer] # hash of renderers
      end

      def renderer(_cite)
        @renderer[:default]
      end

      # takes array of { id, type, author, date, ord, data_liquid }
      def render(ret)
        cites = citations(ret)
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
        t = renderer(cite).renderer(cite[:type] || "misc").template_raw
        c = cite[:data_liquid]
        t.is_a?(String) or return
        (/\{\{\s*date_accessed\s*\}\}/.match?(t) &&
        /\{\{\s*uri\s*\}\}/.match?(t) &&
        c[:uri_raw] && !c[:date_accessed]) or return
        c[:uri_raw]
      end

      def add_date_accessed(data, uri, status)
        r = renderer(data)
        if status
          data[:data_liquid][:date_accessed] = { on: ::Date.today.to_s }
          data[:data_liquid] = r.fieldsklass.new(renderer: r)
            .compound_fields_format(data[:data_liquid])
        else
          r.url_warn(uri)
        end
      end

      def render1(cit)
        ref, ref1, r = render1_prep(cit)
        cit[:formattedref] =
          r.valid_parse(@i18n.l10n(ref1))
        cit[:citation][:full] = r.valid_parse(@i18n.l10n(ref))
        %i(type data_liquid renderer).each { |x| cit.delete(x) }
        cit
      end

      def use_terminator?(ref, final, _cit)
        !ref || ref.empty? and return false
        !ref.end_with?(final)
      end

      def render1_prep(cit)
        r = renderer(cit)
        ref = r.renderer(cit[:type] || "misc").render(cit[:data_liquid])
        final = @i18n.get.dig("punct", "biblio-terminator") || "."
        ref1 = ref
        use_terminator?(ref, final, cit) and ref1 += final
        [ref, ref1, r]
      end

      # TODO: configure how multiple ids are joined, from template?
      def citations(ret)
        ret = disambig_author_date_citations(ret)
        ret.each_value do |b|
          b[:citation][:default] =
            @i18n.l10n(b[:data_liquid][:authoritative_identifier]&.first || "")
          b[:citation][:short] = @i18n.l10n(renderer(b).citeshorttemplate
            .render(b[:data_liquid].merge(citestyle: "short")))
          citations_iterate_cite_styles(b)
        end
        ret
      end

      def citations_iterate_cite_styles(bib)
        r = renderer(bib)
        r.citetemplate.citation_styles.each do |style|
          bib[:citation][style] =
            @i18n.l10n(r.citetemplate.render(bib.merge(citestyle: style)
            .merge(bib[:data_liquid])))
        end
      end

      # takes array of { id, type, author, date, ord, data_liquid }
      def disambig_author_date_citations(ret)
        author_date_to_hash(suffix_date(sort_ord(author_date_breakdown(ret))))
      end

      def author_date_breakdown(ret)
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
        key1.nil? and return
        ret[key1][key2].each_with_index do |b, i|
          b[:date].nil? and next
          b[:date] += ("a".ord + i).chr.to_s
          b[:data_liquid][:date] = b[:date]
        end
      end

      def author_date_to_hash(ret)
        ret.each_with_object({}) do |(_k, v), m|
          v.each_value do |v1|
            v1.each do |b|
              m[b[:id]] = { author: @i18n.l10n(b[:author]), date: b[:date],
                            citation: {},
                            data_liquid: b[:data_liquid], type: b[:type] }
            end
          end
        end
      end
    end
  end
end
