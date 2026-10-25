# frozen_string_literal: true

# The gem's require entry: the public rendering surface — General (the
# localized multi-renderer front) and the ISO 690 engine with its
# CitationStyle loader. Styles are data (lib/relaton/render/iso690/styles);
# the engine holds none.
require_relative "render/version"
require_relative "render/general"
require_relative "render/iso690"
