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

  describe "automatic NATIVE_DATABASE_TYPES registration" do
    it "registers multirange types in PostgreSQLAdapter::NATIVE_DATABASE_TYPES" do
      # Trigger the multirange registration
      Activerecord::Multirange.add_multirange_column_type
      ActiveSupport.run_load_hooks(:active_record, ActiveRecord::Base)

      native_types = ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::NATIVE_DATABASE_TYPES

      # Check that all multirange types are registered
      Activerecord::Multirange::MULTIRANGE_TYPES.each do |type_name, type_config|
        expect(native_types).to have_key(type_name)
        expect(native_types[type_name]).to eq(type_config)
      end
    end

    it "does not duplicate types if already registered" do
      # Register types twice to ensure no duplication
      2.times do
        Activerecord::Multirange.add_multirange_column_type
        ActiveSupport.run_load_hooks(:active_record, ActiveRecord::Base)
      end

      native_types = ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::NATIVE_DATABASE_TYPES

      # Count occurrences of multirange types (should only appear once each)
      multirange_keys = native_types.keys.select { |k| k.to_s.include?('multirange') }
      expect(multirange_keys.length).to eq(Activerecord::Multirange::MULTIRANGE_TYPES.length)
    end
  end
end
