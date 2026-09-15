# frozen_string_literal: true

module Relaton
  module Render
    module Iso690
      # relaton-local labels and punctuation (no isodoc-i18n dependency)
      class I18n
        EN = {
          "edition" => "ed",
          "series_no" => "no.",
          "report_no" => "Report no.",
          "available_from" => "Available from:",
          "in" => "In:",
        }.freeze

        def initialize(lang = "en", _script = "Latn")
          @lang = lang
        end

        def label(key)
          EN.fetch(key, key)
        end
      end
    end
  end
end
