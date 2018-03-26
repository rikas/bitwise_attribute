[![Dependency Status](https://gemnasium.com/rikas/bitwise_attribute.svg)](https://gemnasium.com/rikas/bitwise_attribute)
[![Build Status](https://travis-ci.org/rikas/bitwise_attribute.svg?branch=master)](https://travis-ci.org/rikas/bitwise_attribute)

# BitwiseAttribute

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bitwise_attribute'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bitwise_attribute

## Usage

Include `BitwiseAttribute` and then define your attribute with `attr_bitwise`. By default it will
use the singularized name with `_mask`.

For the `roles` attribute you need to have `role_mask` column in your model, so add the migration:

```ruby
class AddRoleMaskToUsers < ActiveRecord::Migration
  def change
    add_column :users, :role_mask, :integer, default: 0
  end
end
```

```ruby
class User < ActiveRecord::Base
  include BitwiseAttribute

  attr_bitwise :roles, values: %i[user moderator admin]
end
```

You can then use

```ruby
user = User.first
user.roles #=> []
user.roles = [:user, :admin] #=> [:user, :admin]
user.save
user.role_mask #=> 5
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run
the tests. You can also run `bin/console` for an interactive prompt that will allow you to
experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new
version, update the version number in `version.rb`, and then run `bundle exec rake release`, which
will create a git tag for the version, push git commits and tags, and push the `.gem` file
to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rikas/bitwise_attribute.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
