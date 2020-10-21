# Evervault

Ruby SDK for [Evervault](https://evervault.com)

## Getting Started

#### Prerequisites

To get started with the Evervault Python SDK, you will need to have created a team on the evervault dashboard.

We are currently in invite-only early access. You can apply for early access [here](https://evervault.com).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'evervault'
```

And then execute:
```sh
     bundle install
```
Or install it yourself as:
```sh
     gem install evervault
```

#### Setup

```ruby
require "evervault"

# Initialize the client with your team's api key
evervault.api_key = <YOUR-API-KEY>

# Encrypt your data and run a cage
result = evervault.encrypt_and_run(<CAGE-NAME>, { hello: 'World!' })
```

## API Reference

#### evervault.encrypt

Encrypt lets you encrypt data for use in any of your evervault cages. You can use it to store encrypted data to be used in a cage at another time.

```ruby
evervault.encrypt(data = Hash | String)
```

| Parameter | Type | Description |
| --------- | ---- | ----------- |
| data | Hash or String | Data to be encrypted |

#### evervault.run

Run lets you invoke your evervault cages with a given payload.

```ruby
evervault.run(cage_name = String, data = Hash)
```

| Parameter | Type | Description |
| --------- | ---- | ----------- |
| cageName | str | Name of the cage to be run |
| data | Hash | Payload for the cage |

#### evervault_client.encryptAndRun

Encrypt your data and use it as the payload to invoke the cage.

```ruby
evervault.encrypt_and_run(cage_name = String, data = Hash)
```

| Parameter | Type | Description |
| --------- | ---- | ----------- |
| cageName | str | Name of the cage to be run |
| data | dict | Data to be encrypted |

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/evervault/evervault-ruby.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
