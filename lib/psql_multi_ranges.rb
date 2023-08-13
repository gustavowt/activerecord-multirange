# frozen_string_literal: true

require "psql_multi_ranges/version"
require "psql_multi_ranges/oid/multi_range"
require "psql_multi_ranges/hooks/psql_hook"
require "psql_multi_ranges/hooks/quoting_hook"
require "psql_multi_ranges/hooks/schema_statements_hook"
require "psql_multi_ranges/hooks/table_definition_hook"
require "psql_multi_ranges/hooks/type_map_hook"
require "active_record"

module PsqlMultiRanges
  class Error < StandardError; end

  def self.add_multirange_column_type
    ActiveSupport.on_load(:active_record) do
      ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.prepend(Hooks::PsqlHook)
      ActiveRecord::ConnectionAdapters::PostgreSQL::OID::TypeMapInitializer.prepend(Hooks::TypeMapHook)
      ActiveRecord::ConnectionAdapters::PostgreSQL::Quoting.prepend(Hooks::QuotingHook)
      ActiveRecord::ConnectionAdapters::PostgreSQL::SchemaStatements.prepend(Hooks::SchemaStatementsHook)
      ActiveRecord::ConnectionAdapters::PostgreSQL::TableDefinition.prepend(Hooks::TableDefinitionHook)
    end
  end
end
