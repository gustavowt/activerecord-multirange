# frozen_string_literal: true

module Activerecord
  module Multirange
    module Adapter
      def initialize_type_map(*params)
        super
        load_multirange_types
      end

      def self.native_database_types
        super.merge(Activerecord::Multirange::MULTIRANGE_TYPES)
      end

      def load_multirange_types
        initializer =
          ::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::OID::TypeMapInitializer
            .new(type_map)
        
        # Query for multirange types and their corresponding base types (not range types)
        # We need to get the range's subtype (e.g., date) not the range type itself
        query = <<-QUERY.squish
          SELECT m.oid, m.typname, m.typelem, m.typdelim, m.typinput, 
                 pr.rngsubtype, m.typtype, m.typbasetype
          FROM pg_type m 
          JOIN pg_type r ON REPLACE(m.typname, 'multirange', 'range') = r.typname
          JOIN pg_range pr ON r.oid = pr.rngtypid
          WHERE m.typtype = 'm';
        QUERY

        # Use exec_query for all Rails versions since execute_and_clear is private
        result = exec_query(query, 'SCHEMA', [])
        # Convert rows to hash format with column names as keys
        records = result.rows.map do |row|
          result.columns.zip(row).to_h
        end
        initializer.register_multirange_type(records)
      end
    end
  end
end
