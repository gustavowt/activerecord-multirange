# frozen_string_literal: true

require 'activerecord-multirange/oid/multi_range'

module Activerecord
  module Multirange
    module TypeMap
      def register_multirange_type(records)
        records.each do |row|
          multirange_oid = row['oid']
          range_oid = row['rngsubtype'] 
          type_name = row['typname']
          
          # Get the range subtype from the type map
          range_type = @store.lookup(range_oid)
          next unless range_type
          
          # Create and register the multirange type
          multirange_type = Activerecord::Multirange::OID::MultiRange.new(
            range_type,
            type_name.to_sym
          )
          
          register(multirange_oid, multirange_type)
        end
      end
    end
  end
end
