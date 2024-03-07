module Relaton
  module Render
    class Parse
      # filter applied across full list of auth_id
      def auth_id_filter(ids)
        id_scope_filter(ids)
      end

      def id_scope_filter(ids)
        ids.detect(&:scope) or return ids
        id_sort_by_scope(ids).each_with_object([]) do |(k, v), m|
          case k
          when "IEEE"
            f = id_extract_by_scope(v, "trademark")
            f.empty? and f = id_extract_by_scope(v, nil)
            m << f
          else m << id_extract_by_scope(v, nil)
          end
        end.flatten
      end

      def id_sort_by_scope(ids)
        ids.each_with_object({}) do |i, m|
          m[i.type] ||= {}
          m[i.type][i.scope] ||= []
          m[i.type][i.scope] << i
        end
      end

      def id_extract_by_scope(idents, key)
        if idents.key?(key)
          idents[key]
        else []
        end
      end

      # list of successive filters on individual auth_id instances
      def auth_id_allow
        [->(x) { x.language == @lang && x.primary },
         ->(x) { x.primary },
         ->(x) { x.language == @lang },
         ->(_x) { true }]
      end

      def authoritative_identifier(doc)
        out = []
        [auth_id_filter(doc.docidentifier), doc.docidentifier].each do |a|
          out = authoritative_identifier_select(a)
          out.empty? or break
        end
        out.map(&:id)
      end

      def authoritative_identifier_select(idents)
        out = []
        auth_id_allow.each do |p|
          out = idents.select do |x|
            p.call(x) &&
              !authoritative_identifier_exclude.include?(id_type_norm(x))
          end
          out.empty? or break
        end
        out
      end

      def authoritative_identifier_exclude
        %w(METANORMA METANORMA-ORDINAL) + other_identifier_include
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
        id.type or return nil
        m = /^(ISBN|ISSN)\./i.match(id.type) or return id.type.upcase
        m[1].upcase
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
    end
  end
end
