# frozen_string_literal: true

require "relaton/render/version"
require "relaton/render/iso690"

module Relaton
  module Render
    # Deprecated 1.x engine leaves, restored so flavor gems that still
    # subclass them load against this line. Superseded by the Iso690
    # engine; removed when the flavors have migrated to CitationStyle
    # instances. Referencing a constant loads its tree on demand.
    autoload :Parse, "relaton/render/parse/parse"
    autoload :Fields, "relaton/render/fields/fields"
    autoload :Date, "relaton/render/fields/date"
    autoload :Template, "relaton/render/template/template"
    autoload :Citations, "relaton/render/legacy/citations"
  end
end
