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
      end

      def role_fields_format(hash)
        hash[:role] = role_inflect(hash[:creators], hash[:role_raw])
        hash[:host_role] =
          role_inflect(hash[:host_creators], hash[:host_role_raw])
      end

      def misc_fields_format(hash)
        hash[:series] = seriesformat(hash)
        hash[:edition] = editionformat(hash[:edition_raw])
        hash[:extent] = extentformat(hash[:extent_raw], hash)
        hash
      end

      def date_fields_format(hash)
        hash[:date] = dateformat(hash[:date], hash)
        hash[:date_updated] = dateformat(hash[:date_updated], hash)
        hash[:date_accessed] = dateformat(hash[:date_accessed], hash)
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

        parts = %i(surname initials given middle)
        names_out = names.each_with_object({}) do |n, m|
          parts.each do |i|
            m[i] ||= []
            m[i] << n[i]
          end
        end
        @r.nametemplate.render(names_out)
      end

      def role_inflect(contribs, role)
        return nil if role.nil? || contribs.size.zero?

        number = contribs.size > 1 ? "pl" : "sg"
        @r.i18n.get[role][number] || role
      end

      def editionformat(edn)
        return edn unless /^\d+$/.match?(edn)

        num = edn.to_i.localize(@r.lang.to_sym)
          .to_rbnf_s(*@r.edition_number)
        @r.edition.sub(/%/, num)
      end

      def extentformat(extent, hash)
        extent.map do |e|
          extent_out = e.merge(type: hash[:type],
                               host_title: hash[:host_title])
            .transform_values do |v|
              v.is_a?(Hash) ? range(v) : v
            end
          @r.extenttemplate.render(extent_out.merge(orig: e))
        end.join("; ")
      end

      def range(hash)
        if hash[:on] then hash[:on]
        elsif hash.has_key?(:from) && hash[:from].nil? then nil
        elsif hash[:from]
          hash[:to] ? "#{hash[:from]}&#x2013;#{hash[:to]}" : hash[:from]
        else hash
        end
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
