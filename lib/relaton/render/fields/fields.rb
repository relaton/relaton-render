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
        misc_fields_format(hash)
      end

      def name_fields_format(hash)
        hash[:creatornames] = nameformat(hash[:creators])
        hash[:host_creatornames] = nameformat(hash[:host_creators])
        hash[:place] = nameformat(hash[:place_raw].map { |x| { nonpersonal: x } })
        hash[:publisher] = nameformat(hash[:publisher_raw])
        hash[:distributor] = nameformat(hash[:distributor_raw])
      end

      def role_fields_format(hash)
        hash[:role] = role_inflect(hash[:creators], hash[:role_raw])
        hash[:host_role] =
          role_inflect(hash[:host_creators], hash[:host_role_raw])
      end

      def misc_fields_format(hash)
        hash[:series] = seriesformat(hash)
        hash[:medium] = mediumformat(hash[:medium_raw])
        hash[:edition] = editionformat(hash[:edition_raw])
        hash[:extent] = extentformat(hash[:extent_raw], hash)
        hash[:size] = sizeformat(hash[:size_raw], hash)
        hash
      end

      def date_fields_format(hash)
        hash[:date] = dateformat(hash[:date], hash)
        hash[:date_updated] = dateformat(hash[:date_updated], hash)
        hash[:date_accessed] = dateformat(hash[:date_accessed], hash)
      end

      # TODO is not being i18n-alised
      def mediumformat(hash)
        return nil if hash.nil?

        %w(content genre form carrier size scale).each_with_object([]) do |i, m|
          m << hash[i] if hash[i]
          m
        end.compact.join(", ")
      end

      def seriesformat(hash)
        parts = %i(series_title series_abbr series_num series_partnumber
                   series_run)
        series_out = parts.each_with_object({}) do |i, m|
          m[i] = hash[i]
        end
        t = hash[:type] == "article" ? @r.journaltemplate : @r.seriestemplate
        t.render(series_out)
      end

      def nameformat(names)
        return names if names.nil?

        parts = %i(surname initials given middle nonpersonal)
        names_out = names.each_with_object({}) do |n, m|
          parts.each do |i|
            m[i] ||= []
            m[i] << n[i]
          end
        end
        @r.nametemplate.render(names_out)
      end

      def role_inflect(contribs, role)
        return nil if role.nil? || contribs.size.zero? ||
          %w(author publisher).include?(role)

        number = contribs.size > 1 ? "pl" : "sg"
        @r.i18n.get[role][number] || role
      end

      def editionformat(edn)
        return edn unless /^\d+$/.match?(edn)

        num = edn
        @r.edition_number and num = edn.to_i.localize(tw_cldr_lang)
          .to_rbnf_s(*@r.edition_number)
        @r.edition.sub(/%/, num)
      end

      def extentformat(extent, hash)
        extent.map do |e|
          e1 = e.transform_values { |v| v.is_a?(Hash) ? range(v) : v }
          ret = e.each_with_object({}) do |(k, v), m|
            extentformat1(k, v, m, e1)
            m
          end
          @r.extenttemplate.render(ret.merge(type: hash[:type]))
        end.join("; ")
      end

      def extentformat1(key, val, hash, norm_hash)
        if %i(volume page).include?(key)
          hash["#{key}_raw".to_sym] = norm_hash[key]
          hash[key] = pagevolformat(norm_hash[key], val, key.to_s, false)
        end
      end

      def range(hash)
        if hash[:on] then hash[:on]
        elsif hash.has_key?(:from) && hash[:from].nil? then nil
        elsif hash[:from]
          hash[:to] ? "#{hash[:from]}&#x2013;#{hash[:to]}" : hash[:from]
        else hash
        end
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
        when "volume"
          hash[:volume_raw] = val
          hash[:volume] = pagevolformat(val, nil, "volume", true)
        when "page"
          hash[:page_raw] = val
          hash[:page] = pagevolformat(val, nil, "page", true)
        when "data" then hash[:data] = val
        when "duration" then hash[:duration] = val
        end
      end

      def pagevolformat(value, value_raw, type, is_size)
        return nil if value.nil?

        num = "pl"
        if is_size
          value == "1" and num = "sg"
        else
          value_raw[:to] or num = "sg"
        end
        @r.i18n.l10n(@r.i18n.get[is_size ? "size" : "extent"][type][num]
          .sub(/%/, value))
      end

      def date_range(hash)
        if hash[:from]
          "#{hash[:from]}&#x2013;#{hash[:to]}"
        else range(hash)
        end
      end

      def dateformat(date, hash)
        return nil if date.nil?

        %i(from to on).each do |k|
          date[k] = daterender(date[k], hash)
        end
        date_range(date)
      end

      def daterender(date, _hash)
        return date if date.nil? || /^\d+$/.match?(date)

        daterender1(date, dategranularity(date), hash)
      end

      def daterender1(date, format, _hash)
        datef = dateparse(date, format, @r.lang.to_sym)
        case @r.date[format]
        when "to_full_s", "to_long_s", "to_medium_s", "to_short_s"
          datef.send @r.date[format]
        else
          datef.to_additional_s(@r.date[format])
        end
      end

      private

      def tw_cldr_lang
        if @r.lang != "zh"
          @r.lang.to_sym
        elsif @r.script == "Hant"
          :"zh-tw"
        else
          :"zh-cn"
        end
      end

      def dategranularity(date)
        case date
        when /^\d+-\d+$/ then "month_year"
        when /^\d+-\d+-\d+$/ then "day_month_year"
        else "date_time"
        end
      end

      def dateparse(date, format, lang)
        case format
        when "date_time" then DateTime.parse(date)
          .localize(lang, timezone: "Zulu")
        when "day_month_year" then DateTime.parse(date)
          .localize(lang, timezone: "Zulu").to_date
        when "month_year" then Date.parse(date)
          .localize(lang, timezone: "Zulu").to_date
        end
      end
    end
  end
end
