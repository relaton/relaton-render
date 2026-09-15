# frozen_string_literal: true

module Relaton
  module Render
    module Iso690
      # Resource types (ISO 690 clause 8)
      module Kinds
        autoload :Monograph, "relaton/render/iso690/kinds/monograph"
        autoload :ComponentPart, "relaton/render/iso690/kinds/component_part"
        autoload :Continuing, "relaton/render/iso690/kinds/continuing"
        autoload :Report, "relaton/render/iso690/kinds/report"
        autoload :Online, "relaton/render/iso690/kinds/online"
        autoload :Patent, "relaton/render/iso690/kinds/patent"

        # relaton type => kind. Order matters: first match wins.
        RESOLUTION = [
          [%w(book), Monograph],
          [%w(patent), Patent],
          [%w(report techreport), Report],
          [%w(webpage website online), Online],
          [%w(article-journal article-magazine serial), Continuing],
        ].freeze

        FALLBACK = Report

        def self.resolve(model)
          type = model.type.to_s
          RESOLUTION.each do |types, kind|
            return kind if types.include?(type)
          end
          FALLBACK
        end
      end
    end
  end
end
