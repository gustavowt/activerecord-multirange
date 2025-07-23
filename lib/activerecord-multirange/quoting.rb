# frozen_string_literal: true

module Activerecord
  module Multirange
    module Quoting
      def quote(value)
        return quote(encode_multirange(value)) if value.is_a?(::Activerecord::Multirange::OID::MultiRange::Data)
        return quote_array_as_multirange(value) if array_of_ranges?(value)

        super
      end

      def type_cast(value)
        return encode_multirange(value) if value.is_a?(::Activerecord::Multirange::OID::MultiRange::Data)
        return encode_array_as_multirange(value) if array_of_ranges?(value)

        super
      end

      # Override the bound value quoting for parameter binding in WHERE clauses
      def quoted_literal(value)
        if array_of_ranges?(value)
          encode_array_as_multirange(value)
        else
          super
        end
      end

      # Override quote_bound_value for newer Rails versions
      def quote_bound_value(value)
        if array_of_ranges?(value)
          "'#{encode_array_as_multirange(value)}'"
        else
          super
        end
      end

      # Override for default expression quoting
      def quote_default_expression(value, column)
        if array_of_ranges?(value)
          "'#{encode_array_as_multirange(value)}'"
        else
          super
        end
      end

      # Override sanitize_sql_array to catch arrays of ranges at parameter binding level
      def sanitize_sql_array(ary)
        statement, *values = ary
        if statement.respond_to?(:to_str)
          # Convert arrays of ranges to multirange format in the values
          converted_values = values.map do |value|
            if array_of_ranges?(value)
              encode_array_as_multirange(value)
            else
              value
            end
          end
          sanitize_sql_for_conditions([statement, *converted_values])
        else
          super
        end
      end

      def encode_multirange(range_data)
        collection = range_data.ranges.map { |r| encode_range(r) }.join(",")

        "{#{collection}}"
      end

      private

      def array_of_ranges?(value)
        value.is_a?(::Array) && value.all? { |item| item.is_a?(::Range) }
      end

      def quote_array_as_multirange(ranges)
        encoded_multirange = encode_array_as_multirange(ranges)
        "'#{encoded_multirange}'"
      end

      def encode_array_as_multirange(ranges)
        collection = ranges.map { |r| encode_range(r) }.join(",")
        "{#{collection}}"
      end
    end
  end
end
