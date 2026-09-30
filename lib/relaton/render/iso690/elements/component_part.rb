# frozen_string_literal: true

module Relaton
  module Render
    module Iso690
      module Elements
        # Component part within a host (ISO 690 clause 7.4): "In: host
        # title, edition of host". Host data comes from the typed
        # partOf relation.
        class ComponentPart < Element
          def present?
            !host_title.empty?
          end

          def render
            "#{@i18n.label('in')} " \
              "#{@style.templates.title_open}#{host_title}" \
              "#{@style.templates.title_close}" \
              "#{host_edition}"
          end

          private

          def relation
            Array(@model.relation).find { |r| r.type == "partOf" }
          end

          def host
            relation&.bibitem
          end

          def host_title
            return localized(relation&.description) if host.nil?

            Array(host.title).map { |t| localized(t) }.join(" ").strip
          end

          def host_edition
            return "" if host.nil?

            edition = Edition.new(host, style: @style, i18n: @i18n)
            return "" unless edition.present?

            ". #{edition.render}"
          end
        end
      end
    end
  end
end
