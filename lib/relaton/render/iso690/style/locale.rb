# frozen_string_literal: true

module Relaton
  module Render
    module Iso690
      class Style
        # LocalizedStrings: per-style overrides of the language pack's
        # connective strings, keyed as in the CitationStyle model.
        class Locale < Lutaml::Model::Serializable
          attribute :conj, :string
          attribute :others, :string
          attribute :no_date, :string
          attribute :no_author, :string
          attribute :in_str, :string
          attribute :at, :string
          attribute :available_at, :string
          # Arbitrary label overrides (edition words, join punctuation,
          # size units): merged over the language pack verbatim.
          attribute :labels, :hash, default: -> { {} }

          key_value do
            map "and", to: :conj
            map "others", to: :others
            map "noDate", to: :no_date
            map "noAuthor", to: :no_author
            map "in", to: :in_str
            map "at", to: :at
            map "availableAt", to: :available_at
            map "labels", to: :labels
          end

          LABEL_FOR = {
            "conj" => "and", "others" => "others", "no_date" => "no_date",
            "no_author" => "no_author", "in_str" => "in", "at" => "at",
            "available_at" => "available_from",
          }.freeze

          def label_map
            base = LABEL_FOR.filter_map do |attr, label|
              value = public_send(attr)
              [label, value] unless value.nil?
            end.to_h
            base.merge(labels || {})
          end
        end
      end
    end
  end
end
