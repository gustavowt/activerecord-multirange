# frozen_string_literal: true

require "activerecord-multirange/version"
require "activerecord-multirange/adapter"
require "activerecord-multirange/quoting"
require "activerecord-multirange/schema_statements"
require "activerecord-multirange/table_definition"
require "activerecord-multirange/type_map"
require "active_record"

module Activerecord
  module Multirange
    class Error < StandardError; end

    def self.add_multirange_column_type
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.prepend(Adapter)
        ActiveRecord::ConnectionAdapters::PostgreSQL::OID::TypeMapInitializer.prepend(TypeMap)
        ActiveRecord::ConnectionAdapters::PostgreSQL::Quoting.prepend(Quoting)
        ActiveRecord::ConnectionAdapters::PostgreSQL::SchemaStatements.prepend(SchemaStatements)
        ActiveRecord::ConnectionAdapters::PostgreSQL::TableDefinition.prepend(TableDefinition)
      end
    end
  end
end
