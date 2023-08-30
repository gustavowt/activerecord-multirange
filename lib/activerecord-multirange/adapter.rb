# frozen_string_literal: true

module Activerecord
  module Multirange
    module Adapter
      def initialize_type_map(*params)
        super
        load_multirange_types
      end

      def native_database_types
        super.merge({
                      datemultirange: { name: "datemultirange" },
                      nummultirange: { name: "nummultirange" },
                      tsmultirange: { name: "tsmultirange" },
                      tstzmultirange: { name: "tstzmultirange" },
                      int4multirange: { name: "int4multirange" },
                      int8multirange: { name: "int8multirange" }
                    })
      end

      def load_multirange_types
        initializer = ::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::OID::TypeMapInitializer.new(type_map)
        query = <<-QUERY
            SELECT t.oid, t.typname, t.typelem, t.typdelim, t.typinput, r.rngsubtype, t.typtype, t.typbasetype
            FROM pg_type as t
            JOIN pg_range as r ON oid = "rngmultitypid";
        QUERY

        execute_and_clear(query, "SCHEMA", []) do |records|
          initializer.register_multirange_type(records)
        end
      end
    end
  end
end
