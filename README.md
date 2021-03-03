[![Build Status](https://travis-ci.org/rikas/bitwise_attribute.svg?branch=master)](https://travis-ci.org/rikas/bitwise_attribute)

# BitwiseAttribute
Manipulation of bitmask attributes in your classes (typically ActiveRecord models). You can have multiple values mapped to the same column — for example when you need a User with multiple roles.

It adds a lot of helper methods so you don't have to deal with the underlying mask.

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

Check the example below to see how to use the helpers and methods created automatically in your classes.

## Examples

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
  
  # This line will do all the magic!
  #
  # By default we assume that your column will be called `role_mask`.
  # You can send the `column_name` option if your column has another name.
  #
  attr_bitwise :roles, values: %i[user moderator admin]
end
```

### Instance manipulation

You can then access the `roles` field without having to know the underlying value of `role_mask`.

```ruby
user = User.new(roles: [:user, :admin])

user.roles
#=> [:user, :admin]

user.role_mask
#=> 5

user.roles << :moderator
user.roles
#=> [:user, :admin, :moderator]
```

You can see if a particular record has a given value:

```ruby
user.admin?
#=> true
```

### Class methods

You can get all available values and correspondent mask value:

```ruby
User.roles
#=> { :user => 1, :moderator => 2, :admin => 4 }
```

So if you need all the keys just use:

```ruby
User.roles.keys
#=> [:user, :moderator, :admin]
```

### ActiveRecord named scopes

BitwiseAttribte will add some methods for easier queries on the database:

```ruby
User.with_roles
#=> Users that have at least one role

User.with_roles(:admin)
#=> Users that have the :admin role

User.with_roles(:admin, :moderator)
#=> Users that have the admin role AND the moderator role

User.with_any_roles(:admin, :moderator)
#=> Users that have the admin role OR the moderator role

User.with_exact_roles(:moderator)
#=> Users that have ONLY the moderator role

User.with_exact_roles(:moderator, :admin)
#=> Users that have ONLY the moderator AND admin roles

User.without_roles(:admin)
#=> Users without the admin role

User.without_roles(:admin, :moderator)
#=> Users without the admin role AND without the moderator role
```

These are the same as using `with_roles`:

```ruby
User.admin
User.user
User.admin.moderator
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
