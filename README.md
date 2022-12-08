[![Evervault](https://evervault.com/evervault.svg)](https://evervault.com/)

[![Unit Tests Status](https://github.com/evervault/evervault-ruby/workflows/evervault-unit-tests/badge.svg)](https://github.com/evervault/evervault-ruby/actions?query=workflow%3Aevervault-unit-tests)

# Evervault Ruby SDK

The [Evervault](https://evervault.com) Ruby SDK is a toolkit for encrypting data as it enters your server, working with Functions, and proxying your outbound API requests to specific domains through [Outbound Relay](https://docs.evervault.com/concepts/outbound-relay/overview) to allow them to be decrypted before reaching their target.

## Getting Started

Before starting with the Evervault Ruby SDK, you will need to [create an account](https://app.evervault.com/register) and a team.

For full installation support, [book time here](https://calendly.com/evervault/support).

## Documentation

See the Evervault [Ruby SDK documentation](https://docs.evervault.com/reference/ruby-sdk).

## Installation

There are two ways to install the Ruby SDK.

#### 1. With Gemfile

Add this line to your application's `Gemfile`:

```ruby
gem 'evervault'
```

Then, run:

```sh
bundle install
```
#### 2. By yourself

Just run:

```sh
gem install evervault
```

## Setup

To make Evervault available for use in your app:

```ruby
require "evervault"

# Initialize the client with your team's API key
Evervault.api_key = <YOUR-API-KEY>

# Encrypt your data
encrypted_data = Evervault.encrypt({ hello: 'World!' })

# Process the encrypted data using a Function
result = Evervault.run(<FUNCTION-NAME>, encrypted_data)

# Send the decrypted data to a third-party API
Evervault.enable_outbound_relay
uri = URI('https://example.com')
req = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
req.body = encrypted_data.to_json
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
res = http.request(req)
```

## Reference

The Evervault Ruby SDK exposes four methods.

### Evervault.encrypt

`Evervault.encrypt` encrypts data for use in your [Evervault Functions](https://docs.evervault.com/concepts/functions/overview). To encrypt data on your server, simply pass a supported value into the `Evervault.encrypt` method and then you can store the encrypted data in your database as normal.

```ruby
Evervault.encrypt(data = String | Number | Boolean | Hash | Array)
```

| Parameter | Type | Description |
| --------- | ---- | ----------- |
| data | `String`, `Number`, `Boolean`, `Hash`, `Array` | Data to be encrypted |

### Evervault.enable_outbound_relay

`Evervault.enable_outbound_relay` configures your application to proxy HTTP requests using Outbound Relay based on the configuration created in the Evervault UI. See [Outbound Relay](https://docs.evervault.com/concepts/outbound-relay/overview) to learn more.  

```ruby
Evervault.enable_outbound_relay([decryption_domains = Array])
```

| Parameter | Type | Description |
| --------- | ---- | ----------- |
| decryption_domains | `Array` | Optional -- Requests sent to any of the domains listed will be proxied through Outbound Relay. This will override the configuration created using the Evervault UI. |

### Evervault.run

`Evervault.run` invokes a Function with a given payload.

```ruby
Evervault.run(function_name = String, data = Hash[, options = Hash])
```

| Parameter | Type | Description |
| --------- | ---- | ----------- |
| function_name | String | Name of the Function to be run |
| data | Hash | Payload for the Function |
| options | Hash | [Options for the Function run](#Function-Run-Options) |

#### Function Run Options

| Option | Type | Default | Description |
| ------ | ---- | ------- | ----------- |
| `async` | `Boolean` | `false` | Run your Function in async mode. Async Function runs will be queued for processing. |
| `version` | `Integer` | `nil` | Specify the version of your Function to run. By default, the latest version will be run. |

### Evervault.create_run_token

`Evervault.create_run_token` creates a single use, time bound token for invoking a Function.

```ruby
Evervault.create_run_token(function_name = String, data = Hash)
```

| Parameter | Type   | Description                                          |
| --------- | ------ | ---------------------------------------------------- |
| function_name | String | Name of the Function the run token should be created for |
| data      | Hash   | Payload that the token can be used with              |

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

[Rbenv](https://github.com/rbenv/rbenv) can also be used to install specific versions of Ruby.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/evervault/evervault-ruby.

## Feedback

Questions or feedback? [Let us know](mailto:support@evervault.com).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
