# frozen_string_literal: true

require "spec_helper"

RSpec.describe "TsMultirangeType" do
  let(:multiranges) do
    [
      Time.parse("2022-05-05 09:30:00 UTC")...Time.parse("2022-06-06 16:30:00 UTC"),
      Time.parse("2022-07-01 08:30:00 UTC")..Time.parse("2022-07-22 11:30:00 UTC"),
      Time.parse("2022-10-01 11:30:00 UTC")...::Float::INFINITY
    ]
  end

  it "respond to correct type" do
    expect(TestingRecord.new.column_for_attribute(:column_ts).type).to eq :tsmultirange
  end

  it "initialize tsmultirange" do
    record = TestingRecord.new(column_ts: multiranges)

    expect(record.column_ts).to eq multiranges
  end

  it "create tsmultirange" do
    record = TestingRecord.create(column_ts: multiranges)

    expect(record.reload.column_ts).to eq multiranges
  end

  it "update tsmultirange" do
    record = TestingRecord.create(column_ts: multiranges)

    new_multiranges = [
      Time.parse("2021-05-05 09:30:00 UTC")...Time.parse("2021-06-06 16:30:00 UTC"),
      Time.parse("2021-07-01 08:30:00 UTC")..Time.parse("2021-07-22 11:30:00 UTC"),
      Time.parse("2021-10-01 11:30:00 UTC")...::Float::INFINITY
    ]

    record.update(column_ts: new_multiranges)

    expect(record.reload.column_ts).to eq new_multiranges
  end

  it "parse values on where clause" do
    record = TestingRecord.create(column_ts: multiranges)

    expect(TestingRecord.where(column_ts: multiranges).pluck(:id)).to eq [record.id]
  end

  context "when values overlap each other" do
    let(:multiranges) do
      [
        Time.parse("2022-05-05 09:30:00 UTC")...Time.parse("2022-06-06 16:30:00 UTC"),
        Time.parse("2022-06-05 08:30:00 UTC")..Time.parse("2022-07-22 11:30:00 UTC"),
        Time.parse("2022-10-01 11:30:00 UTC")...::Float::INFINITY
      ]
    end

    it "postgres recalculate it" do
      record = TestingRecord.create(column_ts: multiranges)

      expect(record.reload.column_ts).to(
        eq([
             Time.parse("2022-05-05 09:30:00 UTC")..Time.parse("2022-07-22 11:30:00 UTC"),
             Time.parse("2022-10-01 11:30:00 UTC")...::Float::INFINITY
           ])
      )
    end
  end
end
