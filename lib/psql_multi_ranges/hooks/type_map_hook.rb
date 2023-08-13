# frozen_string_literal: true

module PsqlMultiRanges
  module Hooks
    module TypeMapHook
      def register_multirange_type(records)
        records.each do |row|
          register_with_subtype(row["oid"], row["rngsubtype"].to_i) do |subtype|
            PsqlMultiRanges::OID::MultiRange.new(subtype, row["typname"].to_sym)
          end
        end
      end
    end
  end
end
