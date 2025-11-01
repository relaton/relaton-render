require_relative "date"

module Relaton
  module Render
    class Fields
      def initialize(options)
        @r = options[:renderer]
      end

      # the @i18n.select choices here need to rely on
      # fields already present, they can't rely on fields they are yet to build
      def compound_fields_format(hash)
        name_fields_format(hash)
        role_fields_format(hash)
        date_fields_format(hash)
        edition_fields_format(hash)
        place_fields_format(hash)
        series_fields_format(hash)
        misc_fields_format(hash)
      end

      def comma(hash)
        "#{@r.i18n.select(hash).dig('punct', 'comma') || ','} "
      end

      def place_fields_format(hash)
        hash[:place_raw]&.map! do |p|
          # TODO use enum-comma?
          if p.is_a?(Array)
            p.join(comma(hash))
          else p
          end
        end
        hash[:place] =
          nameformat(hash[:place_raw].map { |x| { nonpersonal: x } }, hash)
      end

      def name_fields_format(hash)
        [%i(creatornames creators), %i(host_creatornames host_creators),
         %i(publisher publisher_raw), %i(distributor distributor_raw),
         %i(authorizer authorizer_raw)]
          .each do |k|
          hash[k[0]] = nameformat(hash[k[1]], hash)
        end
        hash[:publisher_abbrev] = hash[:publisher_abbrev_raw]&.join(comma(hash))
        hash[:authorcite] = authorciteformat(hash[:creators], hash)
      end

      def role_fields_format(hash)
        hash[:role] = role_inflect(hash[:creators], hash[:role_raw], hash)
        hash[:host_role] =
          role_inflect(hash[:host_creators], hash[:host_role_raw], hash)
      end

      def edition_fields_format(hash)
        hash[:edition] =
          editionformat(hash[:edition_raw], hash[:edition_num], hash)
        hash[:draft] = draftformat(hash[:draft_raw], hash)
      end

      def misc_fields_format(hash)
        hash[:medium] = mediumformat(hash[:medium_raw], hash)
        hash[:extent] = extentformat(hash[:extent_raw], hash)
        hash[:size] = sizeformat(hash[:size_raw], hash)
        hash[:uri] = uriformat(hash[:uri_raw])
        hash[:status] = statusformat(hash[:status_raw], hash)
        hash[:other_identifier] =
          otheridentifierformat(hash[:other_identifier_raw], hash)
        hash
      end

      def otheridentifierformat(otherids, _hash)
        otherids&.map do |i|
          # ret = "#{i[0]}: <esc>#{i[1]}</esc>"
          # @r.i18n.select(hash).l10n(ret) # no i18n!
          "#{i[0]}: #{i[1]}"
        end
      end

      def statusformat(status, hash)
        status.nil? and return
        @r.i18n.select(hash).get.dig("stage", status) || status
      end

      def date_fields_format(hash)
        [%i(date date), %i(date_updated date_updated),
         %i(date_accessed date_accessed)].each do |k|
          hash[k[0]] = dateformat(hash[k[1]], hash, k)
          k[0] == :date &&
            !%w(standard webresource website).include?(hash[:type]) and
            hash[k[0]] ||= @r.i18n.select(nil).get["no_date"]
        end
      end

      def mediumformat(medium, hash)
        medium.nil? and return nil
        ret = %w(content genre form carrier size
                 scale).each_with_object([]) do |i, m|
          m << "<esc>#{medium[i]}</esc>" if medium[i]
          m
        end.compact
        i = @r.i18n.select(hash)
        i.l10n(ret.join(comma(hash)))
      end

      def series_fields_format(hash)
        parts =
          %i(series_title series_abbr series_num series_partnumber
             series_run series_formatted series_dates series_place series_org)
        series_out = parts.each_with_object({}) do |i, m|
          m[i] = hash[i]
        end
        t = hash[:type] == "article" ? @r.journaltemplate : @r.seriestemplate
        hash[:series] = t.render(series_out, hash)
      end

      def nameformat(names, hash)
        names.nil? and return names
        parts = %i(surname initials given middle nonpersonal)
        names_out = names.each_with_object({}) do |n, m|
          parts.each do |i|
            m[i] ||= []
            m[i] << n[i]
          end
        end
        @r.nametemplate.render(names_out, hash)
      end

      def authorciteformat(names, hash)
        names.nil? || @r.authorcitetemplate.nil? and return names
        parts = %i(surname initials given middle nonpersonal)
        names_out = names.each_with_object({}) do |n, m|
          parts.each do |i|
            m[i] ||= []
            m[i] << n[i]
          end
        end
        @r.authorcitetemplate.render(names_out, hash)
      end

      def role_inflect(contribs, role, hash)
        role.nil? || contribs.empty? ||
          %w(author publisher distributor
             authorizer).include?(role) and return nil
        number = contribs.size > 1 ? "pl" : "sg"
        x = @r.i18n.select(hash).get[role]
        x.is_a?(Hash) or return role
        x[number] || role
      end

      def editionformat(edn, num, hash)
        num || edn && !edn.empty? or return
        edn_num = edn&.gsub(/<\/?esc>/, "")
        num || /^\d+$/.match?(edn_num) and
          return @r.i18n.select(hash).populate("edition_ordinal",
                                               { "var1" => num || edn_num.to_i })
        @r.i18n.select(hash).populate("edition_cardinal", { "var1" => edn })
      end

      def draftformat(num, hash)
        num.nil? ||
          (num.is_a?(Hash) && num[:status].nil? &&
            num[:iteration].nil?) and return nil
        @r.i18n.select(hash).draft.sub("%", num)
      end

      def extentformat(extent, hash)
        extent.map do |stack|
          stack.map do |e|
            e1 = e.transform_values { |v| v.is_a?(Hash) ? range(v) : v }
            ret = e.each_with_object({}) do |(k, v), m|
              extentformat1(k, v, m, e1)
              m
            end
            @r.extenttemplate.render(hash.merge(ret), hash)
          end.join(" ")
        end.join("; ")
      end

      def extentformat1(key, val, hash, norm_hash)
        if %i(volume issue page).include?(key)
          hash["#{key}_raw".to_sym] = norm_hash[key]
          hash[key] = pagevolformat(norm_hash[key], val, key.to_s, false, hash)
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

        ret = size.transform_values do |v|
          @r.i18n.select(hash).l10n(v.join(" + "))
        end
          .each_with_object({}) do |(k, v), m|
            sizeformat1(k, v, m)
            m
          end
        @r.sizetemplate.render(ret.merge(type: hash[:type]), hash)
      end

      def sizeformat1(key, val, hash)
        case key
        when "volume", "issue", "page"
          hash["#{key}_raw".to_sym] = val
          hash[key.to_sym] = pagevolformat(val, nil, key, true, hash)
        when "data" then hash[:data] = val
        when "duration" then hash[:duration] = val
        end
      end

      def pagevolformat(value, value_raw, type, is_size, hash)
        value.nil? and return nil
        num = "pl"
        if is_size
          value == "1" and num = "sg"
        else
          value_raw[:to] or num = "sg"
        end
        i = @r.i18n.select(hash)
        i.l10n(i.get[is_size ? "size" : "extent"][type][num]
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
        # do not process uri contents in l10n
        "<link target='#{uri}'><esc>#{uri}</esc></link>"
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
