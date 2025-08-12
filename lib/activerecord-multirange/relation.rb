# frozen_string_literal: true

module Activerecord
  module Multirange
    module Relation
      def where(*args)
        if args.length > 1 && args.first.is_a?(String)
          # Convert any arrays of ranges in the parameters to multirange format
          converted_rest = args.from(1).map do |param|
            if array_of_ranges?(param)
              encode_array_as_multirange(param)
            else
              param
            end
          end
          super(args.first, *converted_rest)
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
