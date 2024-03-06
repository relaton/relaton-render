module Relaton
  module Render
    class Date
      def initialize(date, options)
        @date = date
        @r = options[:renderer]
        @type = options[:type]
        @bibitem = options[:bibitem]
      end

      def render
        return @date if @date.nil? || /^\d+$/.match?(@date)

        render1(granularity)
      end

      def render1(format)
        datef = dateparse(format, @r.lang.to_sym)
        case @r.date[format]
        when "to_full_s", "to_long_s", "to_medium_s", "to_short_s"
          datef.send @r.date[format]
        else
          datef.to_additional_s(@r.date[format])
        end
      end

      def granularity
        case @date
        when /^\d+-\d+$/ then "month_year"
        when /^\d+-\d+-\d+$/ then "day_month_year"
        else "date_time"
        end
      end

      def dateparse(format, lang)
        case format
        when "date_time"
          DateTime.parse(@date).localize(lang, timezone: "Zulu")
        when "day_month_year"
          DateTime.parse(@date).localize(lang, timezone: "Zulu").to_date
        when "month_year"
          DateTime.parse("#{@date}-01").localize(lang, timezone: "Zulu").to_date
        end
      end
    end
  end
end
