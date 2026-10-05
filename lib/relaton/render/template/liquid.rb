module Relaton
  module Render
    module Template
      module CustomFilters
        def capitalize_first(words)
          words.nil? and return nil
          # Split while preserving delimiters (spaces/underscores) and extracting XML tags
          ret = words.split(/(<[^>]+>|[ _])/).reject(&:empty?)
          # Find and capitalize the first element that is not a delimiter or XML tag
          ret.each do |element|
            element.match?(/^[ _]$/) || element.match?(/^<[^>]+>$/) and next
            element.capitalize!
            break
          end
          # Join with empty string since delimiters are preserved
          ret.join.sub(/^[ _]+/, "").sub(/[ _]+$/, "")
        end

        def selective_upcase(text)
          text.nil? and return nil
          # Split to extract both +++...+++ sections and XML tags
          text.split(/(\+\+\+[^+]+?\+\+\+|<[^<>]+>)/).map do |n|
            if m = /^\+\+\+(.+)\+\+\+$/.match(n)
              m[1] # Keep content inside +++ unchanged
            elsif n.match?(/^<[^>]+>$/)
              n # Keep XML tags unchanged
            else n.upcase # Upcase everything else
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
