# frozen_string_literal: true

require "spec_helper"

RSpec.describe "NumMultirangeType" do
  let(:multiranges) do
    [BigDecimal("12")..BigDecimal("30"), BigDecimal("500")...BigDecimal("750"),
     BigDecimal("1000.2")...::Float::INFINITY]
  end

  it "respond to correct type" do
    expect(TestingRecord.new.column_for_attribute(:column_num).type).to eq :nummultirange
  end

  it "initialize nummultirange" do
    record = TestingRecord.new(column_num: multiranges)

    expect(record.column_num).to eq multiranges
  end

  it "create nummultirange" do
    record = TestingRecord.create(column_num: multiranges)

    expect(record.reload.column_num).to eq multiranges
  end

  it "update nummultirange" do
    record = TestingRecord.create(column_num: multiranges)

    new_multiranges = [BigDecimal("32.3")..BigDecimal("50.2"), BigDecimal("900.2")...::Float::INFINITY]

    record.update(column_num: new_multiranges)

    expect(record.reload.column_num).to eq new_multiranges
  end

  it "parse values on where clause" do
    record = TestingRecord.create(column_num: multiranges)

    expect(TestingRecord.where(column_num: multiranges).pluck(:id)).to eq [record.id]
  end

  context "when values overlap each other" do
    let(:multiranges) do
      [
        BigDecimal("32.3")..BigDecimal("50.2"),
        BigDecimal("42.5")..BigDecimal("300.4"),
        BigDecimal("900.2")...::Float::INFINITY
      ]
    end

    it "postgres recalculate it" do
      record = TestingRecord.create(column_num: multiranges)

      expect(record.reload.column_num).to eq(
        [
          BigDecimal("32.3")..BigDecimal("300.4"),
          BigDecimal("900.2")...::Float::INFINITY
        ]
      )
    end
  end
end
