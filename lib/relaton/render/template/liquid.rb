module Relaton
  module Render
    module Template
      module CustomFilters
        def capitalize_first(words)
          return nil if words.nil?

          # Split while preserving delimiters (spaces/underscores) and extracting XML tags
          ret = words.split(/(<[^>]+>|[ _])/).reject(&:empty?)
          
          # Find and capitalize the first element that is not a delimiter or XML tag
          ret.each do |element|
            # Skip delimiters (space or underscore) and XML tags
            next if element.match?(/^[ _]$/) || element.match?(/^<[^>]+>$/)
            
            # Capitalize the first actual word
            element.capitalize!
            break
          end
          # Join with empty string since delimiters are preserved
          ret.join("").sub(/^[ _]+/, "").sub(/[ _]+$/, "")
        end

        def selective_upcase(text)
          return nil if text.nil?

          # Split to extract both +++...+++ sections and XML tags
          ret = text.split(/(\+\+\+[^+]+?\+\+\+|<[^<>]+>)/)
          ret.map do |n|
            if m = /^\+\+\+(.+)\+\+\+$/.match(n)
              # Keep content inside +++ unchanged
              m[1]
            elsif n.match?(/^<[^>]+>$/)
              # Keep XML tags unchanged
              n
            else
              # Upcase everything else
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
