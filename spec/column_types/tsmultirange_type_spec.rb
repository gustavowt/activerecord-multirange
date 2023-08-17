# frozen_string_literal: true

require "spec_helper"

RSpec.describe "TsMultirangeType" do
  it "initialize tsmultirange" do
    multiranges = [10.days.ago..9.days.ago, 5.days.ago...Time.current]
    record = TestingRecord.new(column_ts: multiranges)

    expect(record.column_ts).to eq multiranges
  end

  it "create tsmultirange" do
    multiranges = [10.days.ago..9.days.ago, 5.days.ago...Time.current]
    record = TestingRecord.create(column_ts: multiranges)

    expect(record.reload.column_ts).to eq multiranges
  end

  it "update tsmultirange" do
    multiranges = [10.days.ago..9.days.ago, 5.days.ago...Time.current]
    record = TestingRecord.create(column_ts: multiranges)

    new_multiranges = [1.week.from_now..2.weeks.from_now, 1.month.from_now..2.months.from_now]
    record.update(column_ts: new_multiranges)

    expect(record.reload.column_ts).to eq new_multiranges
  end
end
