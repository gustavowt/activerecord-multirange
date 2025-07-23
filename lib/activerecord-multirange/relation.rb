# frozen_string_literal: true

module Activerecord
  module Multirange
    module Relation
      def where(opts = :chain, *rest)
        if opts.is_a?(String) && rest.any?
          # Convert any arrays of ranges in the parameters to multirange format
          converted_rest = rest.map do |param|
            if array_of_ranges?(param)
              encode_array_as_multirange(param)
            else
              param
            end
          end
          super(opts, *converted_rest)
        else
          super
        end
      end

      private

      def array_of_ranges?(value)
        value.is_a?(::Array) && value.all? { |item| item.is_a?(::Range) }
      end

      def encode_array_as_multirange(ranges)
        collection = ranges.map { |r| connection.send(:encode_range, r) }.join(",")
        "{#{collection}}"
      end
    end
  end
end 