# frozen_string_literal: true

require 'activerecord-multirange/version'
require 'activerecord-multirange/adapter'
require 'activerecord-multirange/quoting'
require 'activerecord-multirange/schema_statements'
require 'activerecord-multirange/table_definition'
require 'activerecord-multirange/type_map'
require 'activerecord-multirange/relation'
require 'active_record'

module Activerecord
  module Multirange
    class Error < StandardError
    end

    # Multirange types that need to be registered
    MULTIRANGE_TYPES = {
      tsmultirange: { name: "tsmultirange" },
      datemultirange: { name: "datemultirange" },
      tstzmultirange: { name: "tstzmultirange" },
      nummultirange: { name: "nummultirange" },
      int8multirange: { name: "int8multirange" },
      int4multirange: { name: "int4multirange" }
    }.freeze

    def self.add_multirange_column_type
      ActiveSupport.on_load(:active_record) do
        # Register multirange types in NATIVE_DATABASE_TYPES for Rails 8 compatibility
        Activerecord::Multirange.register_native_database_types

        ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.prepend(Adapter)
        ActiveRecord::ConnectionAdapters::PostgreSQL::OID::TypeMapInitializer
          .prepend(TypeMap)
        ActiveRecord::ConnectionAdapters::PostgreSQL::Quoting.prepend(Quoting)
        ActiveRecord::ConnectionAdapters::PostgreSQL::SchemaStatements.prepend(
          SchemaStatements
        )
        ActiveRecord::ConnectionAdapters::PostgreSQL::TableDefinition.prepend(
          TableDefinition
        )
        ActiveRecord::Relation.prepend(Relation)
      end
    end

    def self.register_native_database_types
      # Ensure the PostgreSQL adapter is loaded
      return unless defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)

      adapter_class = ActiveRecord::ConnectionAdapters::PostgreSQLAdapter

      # Check if NATIVE_DATABASE_TYPES is already defined and modifiable
      if adapter_class.const_defined?(:NATIVE_DATABASE_TYPES)
        current_types = adapter_class::NATIVE_DATABASE_TYPES
        
        # Only modify if our types aren't already registered
        unless current_types.key?(:tsmultirange)
          # Create a new hash with existing types plus our multirange types
          new_types = current_types.merge(MULTIRANGE_TYPES)
          
          # Replace the constant with the updated hash
          adapter_class.send(:remove_const, :NATIVE_DATABASE_TYPES)
          adapter_class.const_set(:NATIVE_DATABASE_TYPES, new_types.freeze)
        end
      end
    end
  end
end
