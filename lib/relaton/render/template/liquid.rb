module Relaton
  module Render
    module Template
      module CapitalizeFirst
        def capitalize_first(words)
          return nil if words.nil?

          ret = words.split(/[ _]/)
          ret.first.capitalize! if ret.size.positive?
          ret.join("_")
        end
      end
    end
  end
end
