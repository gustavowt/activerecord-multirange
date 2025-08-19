# frozen_string_literal: true

require "spec_helper"
require "bigdecimal"

RSpec.describe "ActiveRecord Attribute API with multirange modifier" do
  before do
    ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS test_models")
    ActiveRecord::Base.connection.execute(<<~SQL)
      CREATE TABLE test_models (
        id SERIAL PRIMARY KEY,
        ranges INT4MULTIRANGE
      )
    SQL
  end

  after do
    ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS test_models")
  end

  let(:model_class) do
    Class.new(ActiveRecord::Base) do
      self.table_name = "test_models"
      attribute :ranges, :integer, multirange: true, default: [1..9999]
    end
  end

  it "allows declaring multirange attributes with the attribute API" do
    expect { model_class }.not_to raise_error
  end

  it "applies default values correctly" do
    instance = model_class.new
    expect(instance.ranges).to eq([1..9999])
  end

  it "can save and retrieve multirange values" do
    instance = model_class.new(ranges: [1..10, 20..30])
    expect(instance.save).to be true
    
    reloaded = model_class.find(instance.id)
    # PostgreSQL int4range uses exclusive upper bounds, so [1..10] becomes [1...11]
    expect(reloaded.ranges).to eq([1...11, 20...31])
  end

  it "works with different base types" do
    # Use decimal instead of bigint since bigint isn't available in all Rails versions
    decimal_model_class = Class.new(ActiveRecord::Base) do
      self.table_name = "test_models"  
      attribute :ranges, :decimal, multirange: true, default: [BigDecimal("1")..BigDecimal("999")]
    end

    instance = decimal_model_class.new
    expect(instance.ranges).to eq([BigDecimal("1")..BigDecimal("999")])
  end

  it "handles nil values" do
    instance = model_class.new(ranges: nil)
    expect(instance.ranges).to be_nil
    expect(instance.save).to be true
  end

  it "handles empty arrays" do
    instance = model_class.new(ranges: [])
    expect(instance.ranges).to eq([])
    expect(instance.save).to be true
  end
end
