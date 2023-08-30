# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Int4multirangeType" do
  let(:multiranges) do
    [-1...5, 12...30, 50...80]
  end

  it "respond to correct type" do
    expect(TestingRecord.new.column_for_attribute(:column_int4).type).to eq :int4multirange
  end

  it "initialize int4multirange" do
    record = TestingRecord.new(column_int4: multiranges)

    expect(record.column_int4).to eq multiranges
  end

  it "create int4multirange" do
    record = TestingRecord.create(column_int4: multiranges)

    expect(record.reload.column_int4).to eq multiranges
  end

  it "update int4multirange" do
    record = TestingRecord.create(column_int4: multiranges)

    new_multiranges = [-3...3, 5...15]

    record.update(column_int4: new_multiranges)

    expect(record.reload.column_int4).to eq new_multiranges
  end

  it "parse values on where clause" do
    record = TestingRecord.create(column_int4: multiranges)

    expect(TestingRecord.where(column_int4: multiranges).pluck(:id)).to eq [record.id]
  end

  context "when values overlap each other" do
    let(:multiranges) { [-5...15, 12..50, 100...200] }

    it "postgres recalculate it" do
      record = TestingRecord.create(column_int4: multiranges)

      expect(record.reload.column_int4).to eq([-5...51, 100...200])
    end
  end
end
