module Relaton
  module Render
    module Utils
      def self.string_keys(hash)
        case hash
        when Hash
          hash.each_with_object({}) do |(k, v), ret|
            ret[k.to_s] = string_keys(v)
          end
        when Array then hash.map { |n| string_keys(n) }
        else hash
        end
      end

      def self.sym_keys(hash)
        case hash
        when Hash
          hash.each_with_object({}) do |(k, v), ret|
            ret[k.to_sym] = sym_keys(v)
          end
        when Array then hash.map { |n| sym_keys(n) }
        else hash
        end
      end
    end
  end
end
