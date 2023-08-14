# Activercord Multirange 
 
This gem adds full suppport of [Postgress Multiranges](https://www.postgresql.org/docs/15/functions-range.html) types.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add activerecord-multirange

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install activerecord-multirange 

## Usage

### Initialize it

```
# config/initializers/activerecord_multirange

Activerecord::Multirange.add_multirange_column_type
```

### Migrations

All multirange types are available on the migrations


```
  t.tsmultirange :column
  t.tstzmultirange :column_tz
  t.datemultirange :column_date
  t.nummultirange :column_num
  t.int8multirange :column_int8
  t.int4multirange :column_int4
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gustavowt/activerecord-multirange.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
