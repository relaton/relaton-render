# frozen_string_literal: true

module Relaton
  module Render
    # Compatibility entry point (relaton-render#90).
    #
    # The v2 engine replaced the liquid/config/i18n machinery with the
    # template evaluator over CitationStyle instances
    # (Relaton::Render::Iso690). isodoc main's render-isodoc subclasses
    # this constant, so it must exist for all-git-main stacks to boot.
    # This facade delegates rendering to the v2 engine; the retired
    # options (config:, template overrides in liquid syntax) are ignored
    # with one warning — migrate to a CitationStyle instance, which
    # expresses everything the old config.yml did (see the citation
    # module in relaton-models).
    class General
      def initialize(options = {})
        @renderer = Iso690::Renderer.new(
          lang: options[:language] || options[:lang] || "en",
          script: options[:script] || "Latn",
          labels: options[:i18nhash] || {},
        )
        warn_general_config if options[:config]
      end

      def render(model, **opts)
        @renderer.render(model, **opts)
      end

      def citation(model, **opts)
        @renderer.citation(model, **opts)
      end

      private

      def warn_general_config
        return if General.config_warned

        General.config_warned = true
        warn "relaton-render: Relaton::Render::General is a compatibility " \
             "facade over the v2 engine; the liquid config option is " \
             "retired and ignored. Author a CitationStyle instance " \
             "(relaton-models citation module) for custom rendering."
      end

      class << self
        attr_accessor :config_warned
      end
    end
  end
end
