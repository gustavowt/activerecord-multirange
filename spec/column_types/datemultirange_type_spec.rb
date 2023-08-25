# frozen_string_literal: true

require "spec_helper"

RSpec.describe "DateMultirangeType" do
  let(:multiranges) do
    [
      Date.new(2022, 1, 2)...Date.new(2022, 1, 4),
      Date.new(2022, 7, 10)...Date.new(2022, 8, 11),
      Date.new(2022, 10, 1)...::Float::INFINITY
    ]
  end

  it "respond to correct type" do
    expect(TestingRecord.new.column_for_attribute(:column_date).type).to eq :datemultirange
  end

  it "initialize datemultirange" do
    record = TestingRecord.new(column_date: multiranges)

    expect(record.column_date).to eq multiranges
  end

  it "create datemultirange" do
    record = TestingRecord.create(column_date: multiranges)

    expect(record.reload.column_date).to eq multiranges
  end

  it "update datemultirange" do
    record = TestingRecord.create(column_date: multiranges)

    new_multiranges = [
      Date.new(2020, 1, 2)...Date.new(2020, 1, 4),
      Date.new(2020, 7, 10)...Date.new(2020, 8, 11),
      Date.new(2020, 10, 1)...::Float::INFINITY
    ]

    record.update(column_date: new_multiranges)

    expect(record.reload.column_date).to eq new_multiranges
  end

  context "when values overlap each other" do
    let(:multiranges) do
      [
        Date.new(2020, 1, 2)...Date.new(2020, 1, 30),
        Date.new(2020, 1, 20)...Date.new(2020, 5, 11),
        Date.new(2020, 10, 1)...::Float::INFINITY
      ]
    end

    it "postgres recalculate it" do
      record = TestingRecord.create(column_date: multiranges)

      expect(record.reload.column_date).to(
        eq([
             Date.new(2020, 1, 2)...Date.new(2020, 5, 11),
             Date.new(2020, 10, 1)...::Float::INFINITY
           ])
      )
    end
  end

  it "parse values on where clause" do
    record = TestingRecord.create(column_date: multiranges)

    expect(TestingRecord.where(column_date: multiranges).pluck(:id)).to eq [record.id]
  end
end
