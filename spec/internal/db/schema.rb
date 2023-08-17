# frozen_string_literal: true

ActiveRecord::Schema.define do
  # Set up any tables you need to exist for your test suite that don't belong
  # in migrations.
  #
  create_table :testing do |t|
    t.tsmultirange :column_ts
    t.tstzmultirange :column_tz
    t.datemultirange :column_date
    t.nummultirange :column_num
    t.int8multirange :column_int8
    t.int4multirange :column_int4

    t.timestamps
  end
end
