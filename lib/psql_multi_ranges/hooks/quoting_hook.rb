# frozen_string_literal: true

module PsqlMultiRanges
  module Hooks
    module QuotingHook
      def quote(value)
        return quote(encode_multirange(value)) if value.is_a?(::PsqlMultiRanges::OID::MultiRange::Data)

        super
      end

      def type_cast(value)
        return encode_multirange(value) if value.is_a?(::PsqlMultiRanges::OID::MultiRange::Data)

        super
      end

      def encode_multirange(range_data)
        collection = range_data.ranges.map { |r| encode_range(r) }.join(",")

        "{#{collection}}"
      end
    end
  end
end
