# frozen_string_literal: true

module Relaton
  module Render
    module Iso690
      # Element registry (ISO 690 clause 7 vocabulary)
      module Elements
        autoload :Creator, "relaton/render/iso690/elements/creator"
        autoload :Title, "relaton/render/iso690/elements/title"
        autoload :Edition, "relaton/render/iso690/elements/edition"
        autoload :Medium, "relaton/render/iso690/elements/medium"
        autoload :Series, "relaton/render/iso690/elements/series"
        autoload :Production, "relaton/render/iso690/elements/production"
        autoload :PubDate, "relaton/render/iso690/elements/pub_date"
        autoload :Identifier, "relaton/render/iso690/elements/identifier"
        autoload :Location, "relaton/render/iso690/elements/location"
        autoload :Numeration, "relaton/render/iso690/elements/numeration"
        autoload :ComponentPart, "relaton/render/iso690/elements/component_part"

        CLASSES = {
          creator: Creator,
          title: Title,
          edition: Edition,
          medium: Medium,
          series: Series,
          production: Production,
          date: PubDate,
          identifier: Identifier,
          location: Location,
          numeration: Numeration,
          component_part: ComponentPart,
        }.freeze

        def self.build(name, model, style:, i18n:)
          CLASSES.fetch(name).new(model, style: style, i18n: i18n)
        end
      end
    end
  end
end
