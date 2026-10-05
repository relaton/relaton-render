module Relaton
  module Render
    module Legacy
      # Deep key transforms the 1.x templates rely on. Copied from the
      # deprecated metanorma-utils implementation so this gem carries no
      # metanorma dependency; method names match so a loaded
      # metanorma-utils simply overrides these.
      module HashCompat
        def stringify_all_keys
          result = {}
          each do |k, v|
            result[k.to_s] = case v
                             when ::Hash, ::Array
                               v.stringify_all_keys
                             else
                               v
                             end
          end
          result
        end

        def symbolize_all_keys
          result = {}
          each do |k, v|
            result[k.to_sym] = case v
                               when ::Hash, ::Array
                                 v.symbolize_all_keys
                               else
                                 v
                               end
          end
          result
        end
      end

      module ArrayCompat
        def stringify_all_keys
          map do |v|
            case v
            when ::Hash, ::Array
              v.stringify_all_keys
            else
              v
            end
          end
        end

        def symbolize_all_keys
          map do |v|
            case v
            when ::Hash, ::Array
              v.symbolize_all_keys
            else
              v
            end
          end
        end
      end
    end
  end
end

Hash.include Relaton::Render::Legacy::HashCompat
Array.include Relaton::Render::Legacy::ArrayCompat
