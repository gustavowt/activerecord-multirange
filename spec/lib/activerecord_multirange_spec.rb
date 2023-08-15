# frozen_string_literal: true

require "active_record/connection_adapters/postgresql_adapter"

RSpec.describe Activerecord::Multirange do
  it "has a version number" do
    expect(Activerecord::Multirange::VERSION).not_to be nil
  end

  it "#add_multirange_column_type, initialize prepend" do
    expect(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter).to(
      receive(:prepend).with(Activerecord::Multirange::Adapter).at_least(:once)
    )
    expect(ActiveRecord::ConnectionAdapters::PostgreSQL::OID::TypeMapInitializer).to(
      receive(:prepend).with(Activerecord::Multirange::TypeMap).at_least(:once)
    )
    expect(ActiveRecord::ConnectionAdapters::PostgreSQL::Quoting).to(
      receive(:prepend).with(Activerecord::Multirange::Quoting).at_least(:once)
    )
    expect(ActiveRecord::ConnectionAdapters::PostgreSQL::SchemaStatements).to(
      receive(:prepend).with(Activerecord::Multirange::SchemaStatements).at_least(:once)
    )
    expect(ActiveRecord::ConnectionAdapters::PostgreSQL::TableDefinition).to(
      receive(:prepend).with(Activerecord::Multirange::TableDefinition).at_least(:once)
    )

    Activerecord::Multirange.add_multirange_column_type
    ActiveSupport.run_load_hooks(:active_record, ActiveRecord::Base)
  end
end
