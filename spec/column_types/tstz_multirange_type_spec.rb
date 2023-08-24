# frozen_string_literal: true

require "spec_helper"

RSpec.describe "TsTzMultirangeType" do
  let(:multiranges) do
    [
      Time.parse("2022-05-05 09:30:00 PDT")...Time.parse("2022-06-06 16:30:00 UTC"),
      Time.parse("2022-07-01 08:30:00 UTC")..Time.parse("2022-07-22 11:30:00 PDT"),
      Time.parse("2022-10-01 11:30:00 -0200")...::Float::INFINITY
    ]
  end

  it "respond to correct type" do
    expect(TestingRecord.new.column_for_attribute(:column_tz).type).to eq :tstzmultirange
  end

  it "initialize tstzmultirange" do
    record = TestingRecord.new(column_tz: multiranges)

    expect(record.column_tz).to eq multiranges
  end

  it "create tstzmultirange" do
    record = TestingRecord.create(column_tz: multiranges)

    expect(record.reload.column_tz).to eq multiranges
  end

  it "update tstzmultirange" do
    record = TestingRecord.create(column_tz: multiranges)

    new_multiranges = [
      Time.parse("2021-05-05 09:30:00 -0300")...Time.parse("2021-06-06 16:30:00 -0500"),
      Time.parse("2021-07-01 08:30:00 PDT")..Time.parse("2021-07-22 11:30:00 UTC"),
      Time.parse("2021-10-01 11:30:00 -0600")...::Float::INFINITY
    ]

    record.update(column_tz: new_multiranges)

    expect(record.reload.column_tz).to eq new_multiranges
  end

  context "when values overlap each other" do
    let(:multiranges) do
      [
        Time.parse("2022-05-05 09:30:00 -0300")...Time.parse("2022-06-06 16:30:00 -0500"),
        Time.parse("2022-06-05 08:30:00 PDT")..Time.parse("2022-07-22 11:30:00 -0400"),
        Time.parse("2022-10-01 11:30:00 -0600")...::Float::INFINITY
      ]
    end

    it "postgres recalculate it" do
      record = TestingRecord.create(column_tz: multiranges)

      expect(record.reload.column_tz).to(
        eq([
             Time.parse("2022-05-05 09:30:00 -0300").utc..Time.parse("2022-07-22 11:30:00 -0400"),
             Time.parse("2022-10-01 11:30:00 -0600").utc...::Float::INFINITY
           ])
      )
    end
  end
end
