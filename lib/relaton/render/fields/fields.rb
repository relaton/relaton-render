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
        hash[:place] = nameformat(hash[:place_raw]&.map do |x|
                                    { nonpersonal: x }
                                  end)
        [%i(creatornames creators), %i(host_creatornames host_creators),
         %i(publisher publisher_raw), %i(distributor distributor_raw)]
          .each do |k|
          hash[k[0]] = nameformat(hash[k[1]])
        end
        hash[:publisher_abbrev] = hash[:publisher_abbrev_raw]&.join(", ")
      end

      def role_fields_format(hash)
        hash[:role] = role_inflect(hash[:creators], hash[:role_raw])
        hash[:host_role] =
          role_inflect(hash[:host_creators], hash[:host_role_raw])
      end

      def edition_fields_format(hash)
        hash[:edition] = editionformat(hash[:edition_raw])
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
          hash[k[0]] = dateformat(hash[k[1]], hash)
        end
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
                   series_run series_formatted)
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

      def draftformat(num, _hash)
        return nil if num.nil?
        return nil if num.is_a?(Hash) && num[:status].nil? && num[:iteration].nil?

        @r.i18n.draft.sub(/%/, num)
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

      def dateformat(date, _hash)
        return nil if date.nil?

        %i(from to on).each do |k|
          date[k] = ::Relaton::Render::Date.new(date[k], renderer: @r).render
        end
        date_range(date)
      end

      def uriformat(uri)
        return nil if uri.nil? || uri.empty?

        "<link target='#{uri}'>#{uri}</link>"
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
    end
  end
end
