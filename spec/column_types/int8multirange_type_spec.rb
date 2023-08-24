# frozen_string_literal: true

require "spec_helper"

RSpec.describe "int8multirangeType" do
  let(:multiranges) do
    [1...5, 12...300, 500...::Float::INFINITY]
  end

  it "respond to correct type" do
    expect(TestingRecord.new.column_for_attribute(:column_int8).type).to eq :int8multirange
  end

  it "initialize int8multirange" do
    record = TestingRecord.new(column_int8: multiranges)

    expect(record.column_int8).to eq multiranges
  end

  it "create int8multirange" do
    record = TestingRecord.create(column_int8: multiranges)

    expect(record.reload.column_int8).to eq multiranges
  end

  it "update int8multirange" do
    record = TestingRecord.create(column_int8: multiranges)

    new_multiranges = [100...200, 700...::Float::INFINITY]

    record.update(column_int8: new_multiranges)

    expect(record.reload.column_int8).to eq new_multiranges
  end

  context "when values overlap each other" do
    let(:multiranges) { [-5000...100, 90..600, 602...::Float::INFINITY] }

    it "postgres recalculate it" do
      record = TestingRecord.create(column_int8: multiranges)

      expect(record.reload.column_int8).to eq([-5000...601, 602...::Float::INFINITY])
    end
  end
end
