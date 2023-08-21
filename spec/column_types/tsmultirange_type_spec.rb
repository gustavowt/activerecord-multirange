# frozen_string_literal: true

require "spec_helper"

RSpec.describe "TsMultirangeType" do
  let(:multiranges) { [10.days.ago.utc..9.days.ago.utc, 5.days.ago.utc...Time.current.utc] }

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

    new_multiranges = [1.week.from_now.utc..2.weeks.from_now.utc, 1.month.from_now.utc..2.months.from_now.utc]
    record.update(column_ts: new_multiranges)

    expect(record.reload.column_ts).to eq new_multiranges
  end
end
