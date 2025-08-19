# frozen_string_literal: true

require "spec_helper"

RSpec.describe "OverlapQueries" do
  describe "queries with && operator" do
    it "quotes array of ranges as multirange in int4multirange overlap queries" do
      record1 = TestingRecord.create(column_int4: [1..10, 20..30])
      record2 = TestingRecord.create(column_int4: [60..70, 80..90])

      # Test the specific case mentioned in the issue: [1..50] should be quoted as '{[1,50]}'
      overlapping_records = TestingRecord.where('column_int4 && ?', [1..50])

      expect(overlapping_records.pluck(:id)).to include(record1.id)
      expect(overlapping_records.pluck(:id)).not_to include(record2.id)
    end

    it "generates correct SQL for array of ranges in overlap queries" do
      TestingRecord.create(column_int4: [1..10, 20..30])

      query = TestingRecord.where('column_int4 && ?', [1..50]).to_sql

      # Should contain '{[1,50]}' not '[1,50]'
      expect(query).to include('{[1,50]}')
      expect(query).not_to include("'[1,50]'")
    end

    it "works with multiple ranges in array parameter" do
      record1 = TestingRecord.create(column_int4: [1..10, 20..30])
      record2 = TestingRecord.create(column_int4: [60..70, 80..90])

      # Test with multiple ranges: should be quoted as '{[1,15],[25,35]}'
      overlapping_records = TestingRecord.where('column_int4 && ?', [1..15, 25..35])

      expect(overlapping_records.pluck(:id)).to include(record1.id)
      expect(overlapping_records.pluck(:id)).not_to include(record2.id)
    end

    it "works with date ranges" do
      date_record1 = TestingRecord.create(
        column_date: [
          Date.new(2022, 1, 1)..Date.new(2022, 1, 15),
          Date.new(2022, 2, 1)..Date.new(2022, 2, 15)
        ]
      )
      date_record2 = TestingRecord.create(
        column_date: [
          Date.new(2022, 6, 1)..Date.new(2022, 6, 15),
          Date.new(2022, 7, 1)..Date.new(2022, 7, 15)
        ]
      )

      overlapping_records = TestingRecord.where(
        'column_date && ?',
        [Date.new(2022, 1, 10)..Date.new(2022, 1, 20)]
      )

      expect(overlapping_records.pluck(:id)).to include(date_record1.id)
      expect(overlapping_records.pluck(:id)).not_to include(date_record2.id)
    end

    it "works with time ranges" do
      time1 = Time.parse("2022-01-01 09:00:00 UTC")
      time2 = Time.parse("2022-01-01 17:00:00 UTC")
      time3 = Time.parse("2022-01-02 09:00:00 UTC")
      time4 = Time.parse("2022-01-02 17:00:00 UTC")

      time_record1 = TestingRecord.create(column_ts: [time1..time2])
      time_record2 = TestingRecord.create(column_ts: [time3..time4])

      search_time1 = Time.parse("2022-01-01 12:00:00 UTC")
      search_time2 = Time.parse("2022-01-01 15:00:00 UTC")

      overlapping_records = TestingRecord.where(
        'column_ts && ?',
        [search_time1..search_time2]
      )

      expect(overlapping_records.pluck(:id)).to include(time_record1.id)
      expect(overlapping_records.pluck(:id)).not_to include(time_record2.id)
    end

    it "works with other multirange operators" do
      record = TestingRecord.create(column_int4: [10..20, 30..40])

      # Test @> (contains) operator
      containing_records = TestingRecord.where('column_int4 @> ?', [15..17])
      expect(containing_records.pluck(:id)).to include(record.id)

      # Test <@ (contained by) operator
      contained_records = TestingRecord.where('? <@ column_int4', [15..17])
      expect(contained_records.pluck(:id)).to include(record.id)
    end

    it "doesn't break `where.not` queries that don't use ranges" do
      expect {
        TestingRecord.where.not('created_at > ?', Time.now)
      }.not_to raise_error
    end
  end
end
