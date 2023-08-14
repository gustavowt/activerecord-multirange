# frozen_string_literal: true

require "activerecord-multirange/oid/multi_range"

module Activerecord
  module Multirange
    module TypeMap
      def register_multirange_type(records)
        records.each do |row|
          register_with_subtype(row["oid"], row["rngsubtype"].to_i) do |subtype|
            Activerecord::Multirange::OID::MultiRange.new(subtype, row["typname"].to_sym)
          end
        end
      end
    end
  end
end
