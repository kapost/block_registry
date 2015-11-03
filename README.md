# BlockRegistry

Register event handlers to key lookups.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'block_registry'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install block_registry

## Usage

Create a `BlockRegistry` instance:

```ruby
registry = BlockRegistry.new
```

Register keys with a processing block:

```ruby
registry.register('user-login') do |email|
  user = User.find_by(email: email)
  puts "User #{user.email} logged in" if user
end

registry.register('user-register') do |email, password|
  user = User.create(email: email, password: password)
  puts "User #{user.email} registered" if user.persisted?
end
```

Call the handler with appropriate arguments:

```ruby
registry.handle('user-register', 'joe@example.com', 'MyPassword123')
registry.handle('user-login', 'joe@example.com')
```

### `BlockRegistry#register`

Registers a handler to a key.  Expects a key name and a block whose arity matches that used by
`BlockRegistry#handle`.  Multiple handlers can be defined for a single key.

```ruby
registry.register('private-message') do |sender_id, recipient_id, message|
  Message.create!(sender_id: sender_id, recipient_id: recipient_id, message: message)
end

registry.register('private-message') do |sender_id, recipient_id, message|
  NewRelic::Agent.notify('private-message', sender_id: sender_id, recipient_id: recipient_id, message: message)
end
```

### `BlockRegistry#registered?`

Returns true or false to signify whether any handlers exist for a given key.

```ruby
registry.register('user-register', &block)
registry.registered?('user-register')  # => true
registry.registered?('user-login')     # => false
```

### `BlockRegistry#unregister`

Unregisters one or all handlers for a key.  If a block is given, the matching handler is
unregistered.  If no block is given, then all handlers for the key are unregistered.

```ruby
block = ->(email) do
  puts "#{email} signed up"
end

registry.register('user-register', &block)
registry.register('user-register') do |email|
  puts 'another handler'
end

registry.unregister('user-register', &block)
registry.registered?('user-register')  # => true

registry.unregister('user-register')
registry.registered?('user-register')  # => false
```

### `BlockRegistry#handles?`

Alias for [`BlockRegistry#registered?`](#blockregistryregistered)

### `BlockRegistry#handle`

Processes a message across all handlers for the given key.

```ruby
registry.register('user-register') { |email| puts "#{email} signed up" }
registry.register('user-register') { |email| puts "hi, #{email}" }

registry.handle('user-register', 'joe@example.com')
# => joe@example.com signed up
# => hi, joe@example.com
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kapost/block_registry.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
