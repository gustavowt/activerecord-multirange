# Activercord Multirange

This gem adds full suppport of [Postgress Multiranges](https://www.postgresql.org/docs/14/rangetypes.html#RANGETYPES-BUILTIN) types.

[![Gem Version](https://badge.fury.io/rb/activerecord-multirange.svg)](https://badge.fury.io/rb/activerecord-multirange)

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add activerecord-multirange

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install activerecord-multirange

## Usage

### Initialize it

```ruby
# config/initializers/activerecord_multirange.rb

Activerecord::Multirange.add_multirange_column_type
```

### Migrations

All multirange types are available in migrations. Here are examples for different multirange types:

```ruby
class CreateSchedules < ActiveRecord::Migration[7.0]
  def change
    create_table :schedules do |t|
      t.string :name
      t.tsmultirange :available_times # Timestamp multirange
      t.tstzmultirange :available_times_tz # Timestamp with timezone multirange
      t.datemultirange :available_dates # Date multirange
      t.nummultirange :price_ranges # Numeric multirange
      t.int8multirange :id_ranges # Bigint multirange
      t.int4multirange :quantity_ranges # Integer multirange

      t.timestamps
    end
  end
end
```

```ruby
class CreateBookings < ActiveRecord::Migration[7.0]
  def change
    create_table :bookings do |t|
      t.string :title
      t.tstzmultirange :booked_periods
      t.datemultirange :blackout_dates

      t.timestamps
    end
  end
end
```

### Models

Define your models to work with multirange columns:

```ruby
class Schedule < ApplicationRecord
  # Multirange columns are automatically handled by ActiveRecord
  # No special configuration needed
end

class Booking < ApplicationRecord
  validates :title, presence: true

  scope :overlapping_with, ->(time_range) { where('booked_periods && ?', time_range) }
end
```

### Creating and Working with Multirange Data

#### Creating Records with Multirange Values

```ruby
# Using timestamp multiranges for scheduling
schedule =
  Schedule.create!(
    name: 'Conference Room A',
    available_times: [
      Time.parse('2024-01-15 09:00')..Time.parse('2024-01-15 12:00'),
      Time.parse('2024-01-15 14:00')..Time.parse('2024-01-15 17:00')
    ]
  )

# Using date multiranges for availability periods
booking =
  Booking.create!(
    title: 'Annual Maintenance',
    booked_periods: [
      Time.zone.parse('2024-03-01 00:00')..Time.zone.parse('2024-03-03 23:59'),
      Time.zone.parse('2024-06-15 00:00')..Time.zone.parse('2024-06-17 23:59')
    ],
    blackout_dates: [
      Date.parse('2024-12-24')..Date.parse('2024-12-26'),
      Date.parse('2024-12-31')..Date.parse('2024-01-01')
    ]
  )

# Using numeric multiranges for pricing tiers
product = Product.create!(name: 'Premium Service', price_ranges: [10.0..50.0, 100.0..500.0, 1000.0..5000.0])
```

#### Reading and Manipulating Multirange Data

```ruby
schedule = Schedule.find(1)

# Access multirange values
puts schedule.available_times
# => [2024-01-15 09:00:00 UTC..2024-01-15 12:00:00 UTC, 2024-01-15 14:00:00 UTC..2024-01-15 17:00:00 UTC]

# Check if multirange contains a specific value
morning_slot = Time.parse('2024-01-15 10:30')
puts schedule.available_times.any? { |range| range.cover?(morning_slot) }
# => true

# Add new time ranges
schedule.available_times += [Time.parse('2024-01-15 18:00')..Time.parse('2024-01-15 20:00')]
schedule.save!

# Working with individual ranges
schedule.available_times.each { |time_range| puts "Available from #{time_range.begin} to #{time_range.end}" }
```

### Querying Multirange Columns

#### Overlap Queries

```ruby
# Find schedules that overlap with a specific time range
search_range = Time.parse('2024-01-15 10:00')..Time.parse('2024-01-15 11:00')
overlapping_schedules = Schedule.where('available_times && ?', search_range)

# Find bookings that don't overlap with a date range
available_dates = Date.parse('2024-03-01')..Date.parse('2024-03-05')
non_conflicting_bookings = Booking.where('NOT (blackout_dates && ?)', available_dates)
```

#### Contains Queries

```ruby
# Find schedules that contain a specific timestamp
specific_time = Time.parse('2024-01-15 10:30')
containing_schedules = Schedule.where('available_times @> ?', specific_time)

# Find products within a specific price range
price_point = 75.0
products_in_range = Product.where('price_ranges @> ?', price_point)
```

#### Other Useful Queries

```ruby
# Check if multirange is contained within another range
broad_range = Time.parse('2024-01-15 08:00')..Time.parse('2024-01-15 18:00')
fully_contained = Schedule.where('available_times <@ ?', broad_range)

# Find records where multiranges are strictly left of a range
cutoff_time = Time.parse('2024-01-15 12:00')..Time.parse('2024-01-15 24:00')
morning_only = Schedule.where('available_times << ?', cutoff_time)

# Find records where multiranges are strictly right of a range
start_time = Time.parse('2024-01-15 00:00')..Time.parse('2024-01-15 12:00')
afternoon_only = Schedule.where('available_times >> ?', start_time)
```

### Practical Examples

#### Availability Scheduling System

```ruby
class Room < ApplicationRecord
  def available_during?(time_range)
    available_times.any? { |range| range.cover?(time_range) }
  end

  def book_time!(time_range)
    # Remove the booked time from available times
    new_availability = []
    available_times.each do |available_range|
      if available_range.overlaps?(time_range)
        # Split the range if needed
        if available_range.begin < time_range.begin
          new_availability << (available_range.begin...time_range.begin)
        end
        if time_range.end < available_range.end
          new_availability << (time_range.end...available_range.end)
        end
      else
        new_availability << available_range
      end
    end

    update!(available_times: new_availability)
  end
end

# Usage
room = Room.find(1)
booking_time = Time.parse('2024-01-15 10:00')..Time.parse('2024-01-15 11:00')

if room.available_during?(booking_time)
  room.book_time!(booking_time)
  puts 'Room booked successfully!'
else
  puts 'Room not available during requested time'
end
```

#### Price Range Management

```ruby
class Product < ApplicationRecord
  def price_tier_for(quantity)
    price_ranges.each_with_index do |range, index|
      if range.cover?(quantity)
        return index + 1
      end
    end
    nil
  end

  def applies_to_quantity?(quantity)
    quantity_ranges.any? { |range| range.cover?(quantity) }
  end
end

# Usage
product = Product.find(1)
puts "Quantity 25 is in tier: #{product.price_tier_for(25)}"
puts "Product applies to quantity 150: #{product.applies_to_quantity?(150)}"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gustavowt/activerecord-multirange.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
