# frozen_string_literal: true

module Relaton
  module Render
    # Citation rendering per the ISO 690 architecture: a kind (resource
    # type, clause 8) walks an ordered stack of elements (data elements,
    # clause 7), omitting those that are not present.
    module Iso690
      autoload :Element, "relaton/render/iso690/element"
      autoload :Elements, "relaton/render/iso690/elements"
      autoload :I18n, "relaton/render/iso690/i18n"
      autoload :IdentifierKinds, "relaton/render/iso690/identifier_kinds"
      autoload :Kind, "relaton/render/iso690/kind"
      autoload :Kinds, "relaton/render/iso690/kinds"
      autoload :Renderer, "relaton/render/iso690/renderer"
      autoload :Style, "relaton/render/iso690/style"
    end
  end
end
