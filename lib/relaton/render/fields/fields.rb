require_relative "date"

module Relaton
  module Render
    class Fields
      def initialize(options)
        @r = options[:renderer]
      end

      def compound_fields_format(hash)
        name_fields_format(hash)
        role_fields_format(hash)
        date_fields_format(hash)
        edition_fields_format(hash)
        misc_fields_format(hash)
      end

      def name_fields_format(hash)
        [%i(creatornames creators), %i(host_creatornames host_creators),
         %i(publisher publisher_raw), %i(distributor distributor_raw),
         %i(authorizer authorizer_raw)]
          .each do |k|
          hash[k[0]] = nameformat(hash[k[1]])
        end
        hash[:publisher_abbrev] = hash[:publisher_abbrev_raw]&.join(", ")
        hash[:authorcite] = authorciteformat(hash[:creators])
        place_format(hash)
      end

      def place_format(hash)
        hash[:place] =
          nameformat(hash[:place_raw].map { |x| { nonpersonal: x } })
      end

      def role_fields_format(hash)
        hash[:role] = role_inflect(hash[:creators], hash[:role_raw])
        hash[:host_role] =
          role_inflect(hash[:host_creators], hash[:host_role_raw])
      end

      def edition_fields_format(hash)
        hash[:edition] = editionformat(hash[:edition_raw], hash[:edition_num])
        hash[:draft] = draftformat(hash[:draft_raw], hash)
      end

      def misc_fields_format(hash)
        hash[:series] = seriesformat(hash)
        hash[:medium] = mediumformat(hash[:medium_raw])
        hash[:extent] = extentformat(hash[:extent_raw], hash)
        hash[:size] = sizeformat(hash[:size_raw], hash)
        hash[:uri] = uriformat(hash[:uri_raw])
        hash
      end

      def date_fields_format(hash)
        [%i(date date), %i(date_updated date_updated),
         %i(date_accessed date_accessed)].each do |k|
          hash[k[0]] = dateformat(hash[k[1]], hash, k)
          k[0] == :date &&
            !%w(standard webresource website).include?(hash[:type]) and
            hash[k[0]] ||= @r.i18n.get["no_date"]
        end
      end

      # TODO is not being i18n-alised
      def mediumformat(hash)
        hash.nil? and return nil
        %w(content genre form carrier size scale).each_with_object([]) do |i, m|
          m << hash[i] if hash[i]
          m
        end.compact.join(", ")
      end

      def seriesformat(hash)
        parts = %i(series_title series_abbr series_num series_partnumber
                   series_run series_formatted series_dates series_place series_org)
        series_out = parts.each_with_object({}) do |i, m|
          m[i] = hash[i]
        end
        t = hash[:type] == "article" ? @r.journaltemplate : @r.seriestemplate
        t.render(series_out)
      end

      def nameformat(names)
        names.nil? and return names
        parts = %i(surname initials given middle nonpersonal)
        names_out = names.each_with_object({}) do |n, m|
          parts.each do |i|
            m[i] ||= []
            m[i] << n[i]
          end
        end
        @r.nametemplate.render(names_out)
      end

      def authorciteformat(names)
        names.nil? || @r.authorcitetemplate.nil? and return names
        parts = %i(surname initials given middle nonpersonal)
        names_out = names.each_with_object({}) do |n, m|
          parts.each do |i|
            m[i] ||= []
            m[i] << n[i]
          end
        end
        @r.authorcitetemplate.render(names_out)
      end

      def role_inflect(contribs, role)
        role.nil? || contribs.empty? ||
          %w(author publisher distributor
             authorizer).include?(role) and return nil
        number = contribs.size > 1 ? "pl" : "sg"
        x = @r.i18n.get[role]
        x.is_a?(Hash) or return role
        x[number] || role
      end

      def editionformat(edn, num)
        num || /^\d+$/.match?(edn) or return edn
        @r.i18n.populate("edition_ordinal", { "var1" => num || edn.to_i })
      end

      def draftformat(num, _hash)
        num.nil? ||
          (num.is_a?(Hash) && num[:status].nil? &&
            num[:iteration].nil?) and return nil
        @r.i18n.draft.sub("%", num)
      end

      def extentformat(extent, hash)
        extent.map do |stack|
        stack.map do |e|
          e1 = e.transform_values { |v| v.is_a?(Hash) ? range(v) : v }
          ret = e.each_with_object({}) do |(k, v), m|
            extentformat1(k, v, m, e1)
            m
          end
          @r.extenttemplate.render(hash.merge(ret))
        end.join(" ")
        end.join("; ")
      end

      def extentformat1(key, val, hash, norm_hash)
        if %i(volume issue page).include?(key)
          hash["#{key}_raw".to_sym] = norm_hash[key]
          hash[key] = pagevolformat(norm_hash[key], val, key.to_s, false)
        end
      end

      def range(hash)
        hash[:on] and return hash[:on]
        hash.has_key?(:from) && hash[:from].nil? and return nil
        !hash[:from] and return hash
        hash[:to] && hash[:to] != hash[:from] and
          return "#{hash[:from]}&#x2013;#{hash[:to]}"
        hash[:from]
      end

      def sizeformat(size, hash)
        return nil unless size

        ret = size.transform_values { |v| @r.i18n.l10n(v.join(" + ")) }
          .each_with_object({}) do |(k, v), m|
            sizeformat1(k, v, m)
            m
          end
        @r.sizetemplate.render(ret.merge(type: hash[:type]))
      end

      def sizeformat1(key, val, hash)
        case key
        when "volume", "issue", "page"
          hash["#{key}_raw".to_sym] = val
          hash[key.to_sym] = pagevolformat(val, nil, key, true)
        when "data" then hash[:data] = val
        when "duration" then hash[:duration] = val
        end
      end

      def pagevolformat(value, value_raw, type, is_size)
        value.nil? and return nil
        num = "pl"
        if is_size
          value == "1" and num = "sg"
        else
          value_raw[:to] or num = "sg"
        end
        @r.i18n.l10n(@r.i18n.get[is_size ? "size" : "extent"][type][num]
          .sub("%", value))
      end

      def date_range(hash)
        hash[:from] && !hash[:to] and return "#{hash[:from]}&#x2013;"
        range(hash)
      end

      def dateformat(date, hash, type)
        date.nil? and return nil
        date.is_a?(String) and return date
        %i(from to on).each do |k|
          date[k] = @r.dateklass
            .new(date[k], renderer: @r, bibitem: hash, type: type).render
        end
        date_range(date)
      end

      def uriformat(uri)
        uri.nil? || uri.empty? and return nil
        "<link target='#{uri}'>#{uri}</link>"
      end

      private

      def tw_cldr_lang
        if @r.lang != "zh" then @r.lang.to_sym
        elsif @r.script == "Hant" then :"zh-tw"
        else :"zh-cn"
        end
      end
    end
  end
end
