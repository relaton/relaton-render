# frozen_string_literal: true

module Relaton
  module Render
    module Iso690
      module Elements
        # The authorizing body of a standard (the IETF RFC Series, the
        # W3C Recommendation process): the organization carrying the
        # authorizer role, cited after the status
        class Authorizer < Element
          def present?
            !authorizer_name.empty?
          end

          def render
            authorizer_name
          end

          private

          def authorizer_name
            contributors("authorizer").map do |c|
              Array(c.organization&.name).map { |n| localized(n) }.join(", ")
            end.reject(&:empty?).first.to_s
          end
        end
      end
    end
  end
end
