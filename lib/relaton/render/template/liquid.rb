module Relaton
  module Render
    module Template
      module CustomFilters
        def capitalize_first(words)
          return nil if words.nil?

          ret = words.split(/[ _]/)
          ret.first.capitalize! if ret.size.positive?
          ret.join("_")
        end

        def selective_upcase(text)
          return nil if text.nil?

          ret = text.split(/(\+\+\+[^+]+?\+\+\+)/)
          ret.map do |n|
            if m = /^\+\+\+(.+)\+\+\+$/.match(n)
              m[1]
            else
              n.upcase
            end
          end.join
        end

        def selective_tag(text, tag)
          return nil if text.nil?

          ret = text.split(/(\+\+\+[^+]+?\+\+\+)/)
          ret.map do |n|
            if m = /^\+\+\+(.+)\+\+\+$/.match(n)
              m[1]
            else
              closetag = tag.sub(/^</, "</")
              "#{tag}#{n}#{closetag}"
            end
          end.join
        end
      end
    end
  end
end
