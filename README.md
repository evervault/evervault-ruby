[![Evervault](https://evervault.com/evervault.svg)](https://welcome.evervault.com/)

[![Unit Tests Status](https://github.com/evervault/evervault-ruby/workflows/evervault-unit-tests/badge.svg)](https://github.com/evervault/evervault-ruby/actions?query=workflow%3Aevervault-unit-tests)

# Evervault Ruby SDK

The [Evervault](https://evervault.com) Ruby SDK is a toolkit for encrypting data as it enters your server, and working with Cages.

## Getting Started

Before starting with the Evervault Ruby SDK, you will need to [create an account](https://app.evervault.com/register) and a team.

For full installation support, [book time here](https://calendly.com/evervault/cages-onboarding).

## Documentation

See the Evervault [Ruby SDK documentation](https://docs.evervault.com/ruby).

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

There are tw ways to make Evervault available for use in your app.

#### 1. As a singleton

The singleton pattern is recommended to prevent additional overhead of loading keys at Cage runtime when creating new Clients.

```ruby
require "evervault"

# Initialize the client with your team's API key
Evervault.api_key = <YOUR-API-KEY>

# Encrypt your data and run a cage
result = Evervault.encrypt_and_run(<CAGE-NAME>, { hello: 'World!' })

# Process the encrypted data in a Cage
result = Evervault.run(<CAGE-NAME>, encrypted)
```

#### 2. Manually

You can manually initialize different clients at different times. For example, if you have multiple Evervault teams and need to switch context.

```ruby
require "evervault"

# Initialize the client with your team's api key
evervault = Evervault::Client.new(api_key: <YOUR-API-KEY>)

# Encrypt your data and run a cage
result = evervault.encrypt_and_run(<CAGE-NAME>, { hello: 'World!' })
```

## Reference

At present, there are seven methods available in the Ruby SDK.

### Evervault.encrypt

`Evervault.encrypt` encrypts data for use in your [Evervault Cages](https://docs.evervault.com/tutorial). To encrypt data on your server, simply pass a `Hash` or `String` into the `Evervault.encrypt` method. Store the encrypted data in your database as normal.

```ruby
Evervault.encrypt(data = Hash | String)
```

| Parameter | Type | Description |
| --------- | ---- | ----------- |
| data | Hash or String | Data to be encrypted |

### Evervault.run

`Evervault.run` invokes a Cage with a given payload.

```ruby
Evervault.run(cage_name = String, data = Hash[, options = Hash])
```

| Parameter | Type | Description |
| --------- | ---- | ----------- |
| cageName | String | Name of the Cage to be run |
| data | Hash | Payload for the Cage |
| options | Hash | [Options for the Cage run](#Cage-Run-Options) |

#### Cage Run Options

| Option | Type | Default | Description |
| ------ | ---- | ------- | ----------- |
| `async` | `Boolean` | `false` | Run your Cage in async mode. Async Cage runs will be queued for processing. |
| `version` | `Integer` | `nil` | Specify the version of your Cage to run. By default, the latest version will be run. |

### Evervault.encrypt_and_run

Encrypt your data and use it as the payload to invoke the Cage.

```ruby
Evervault.encrypt_and_run(cage_name = String, data = Hash)
```

| Parameter | Type | Description |
| --------- | ---- | ----------- |
| cageName | String | Name of the Cage to be run |
| data | dict | Data to be encrypted |

### Evervault.cages

Return a hash of your team's Cage objects in hash format, with cage-name as keys

```ruby
Evervault.cages
=> {"hello-cage-chilly-plum"=>
  #<Evervault::Models::Cage:0x00007f8b900b4438
   @name="hello-cage-chilly-plum",
   @request=#<Evervault::Http::Request:0x00007f8b900b7d40 @api_key="API-KEY", @base_url="https://api.evervault.com/", @cage_run_url="https://cage.run/", @timeout=30>,
   @uuid="c8a7ed58-4858-4510-a542-43125ccd1183">,
 "hello-cage-filthy-fuchsia"=>
  #<Evervault::Models::Cage:0x00007f8b900b43e8
   @name="hello-cage-filthy-fuchsia",
   @request=#<Evervault::Http::Request:0x00007f8b900b7d40 @api_key="API-KEY", @base_url="https://api.evervault.com/", @cage_run_url="https://cage.run/", @timeout=30>,
   @uuid="9af32d2b-53fa-406a-9abf-6a240648b45b">,
 "hello-cage-extra-amaranth"=>
  #<Evervault::Models::Cage:0x00007f8b900b4398
   @name="hello-cage-extra-amaranth",
   @request=#<Evervault::Http::Request:0x00007f8b900b7d40 @api_key="API-KEY", @base_url="https://api.evervault.com/", @cage_run_url="https://cage.run/", @timeout=30>,
   @uuid="5b99011e-a64d-4af7-bf81-619c8cb8c67f">,
 "twilio-cage-explicit-salmon"=>
  #<Evervault::Models::Cage:0x00007f8b900b4348
   @name="twilio-cage-explicit-salmon",
   @request=#<Evervault::Http::Request:0x00007f8b900b7d40 @api_key="API-KEY", @base_url="https://api.evervault.com/", @cage_run_url="https://cage.run/", @timeout=30>,
   @uuid="55986772-4db7-4695-ba44-1b807290ddea">}
```

### Evervault.cage_list

Return a `CageList` object, containing a list of your team's Cages

```ruby
Evervault.cage_list
=> #<Evervault::Models::CageList:0x00007f8b900b44b0
 @cages=
  [#<Evervault::Models::Cage:0x00007f8b900b4438
    @name="hello-cage-chilly-plum",
    @request=#<Evervault::Http::Request:0x00007f8b900b7d40 @api_key="API-KEY", @base_url="https://api.evervault.com/", @cage_run_url="https://cage.run/", @timeout=30>,
    @uuid="c8a7ed58-4858-4510-a542-43125ccd1183">,
   #<Evervault::Models::Cage:0x00007f8b900b43e8
    @name="hello-cage-filthy-fuchsia",
    @request=#<Evervault::Http::Request:0x00007f8b900b7d40 @api_key="API-KEY", @base_url="https://api.evervault.com/", @cage_run_url="https://cage.run/", @timeout=30>,
    @uuid="9af32d2b-53fa-406a-9abf-6a240648b45b">,
   #<Evervault::Models::Cage:0x00007f8b900b4398
    @name="hello-cage-extra-amaranth",
    @request=#<Evervault::Http::Request:0x00007f8b900b7d40 @api_key="API-KEY", @base_url="https://api.evervault.com/", @cage_run_url="https://cage.run/", @timeout=30>,
    @uuid="5b99011e-a64d-4af7-bf81-619c8cb8c67f">,
   #<Evervault::Models::Cage:0x00007f8b900b4348
    @name="twilio-cage-explicit-salmon",
    @request=#<Evervault::Http::Request:0x00007f8b900b7d40 @api_key="API-KEY", @base_url="https://api.evervault.com/", @cage_run_url="https://cage.run/", @timeout=30>,
    @uuid="55986772-4db7-4695-ba44-1b807290ddea">,
   #<Evervault::Models::Cage:0x00007f8b900b42f8
    @name="hello-cage-collective-aquamarine",
    @request=#<Evervault::Http::Request:0x00007f8b900b7d40 @api_key="API-KEY", @base_url="https://api.evervault.com/", @cage_run_url="https://cage.run/", @timeout=30>,
    @uuid="01691e76-691b-473e-aad5-44bf813ef146">,
   #<Evervault::Models::Cage:0x00007f8b900b42a8
    @name="twilio-cage-bored-scarlet",
    @request=#<Evervault::Http::Request:0x00007f8b900b7d40 @api_key="API-KEY", @base_url="https://api.evervault.com/", @cage_run_url="https://cage.run/", @timeout=30>,
    @uuid="dc056e8b-faf3-445b-9c95-0885b983c302">,
   #<Evervault::Models::Cage:0x00007f8b900b4258
    @name="hello-cage-front-emerald",
    @request=#<Evervault::Http::Request:0x00007f8b900b7d40 @api_key="API-KEY", @base_url="https://api.evervault.com/", @cage_run_url="https://cage.run/", @timeout=30>,
    @uuid="a30295e6-91fc-4d1d-837c-ac4c9b87d02d">]>
```

#### CageList.to_hash

Converts a list of Cages to a hash with keys of CageName => Cage Model

```ruby
Evervault.cage_list.to_hash
=> {"hello-cage-chilly-plum"=>
  #<Evervault::Models::Cage:0x00007f8b900b4438
   @name="hello-cage-chilly-plum",
   @request=#<Evervault::Http::Request:0x00007f8b900b7d40 @api_key="API-KEY", @base_url="https://api.evervault.com/", @cage_run_url="https://cage.run/", @timeout=30>,
   @uuid="c8a7ed58-4858-4510-a542-43125ccd1183">,
 "hello-cage-filthy-fuchsia"=>
  #<Evervault::Models::Cage:0x00007f8b900b43e8
   @name="hello-cage-filthy-fuchsia",
   @request=#<Evervault::Http::Request:0x00007f8b900b7d40 @api_key="API-KEY", @base_url="https://api.evervault.com/", @cage_run_url="https://cage.run/", @timeout=30>,
   @uuid="9af32d2b-53fa-406a-9abf-6a240648b45b">,
 "hello-cage-extra-amaranth"=>
  #<Evervault::Models::Cage:0x00007f8b900b4398
   @name="hello-cage-extra-amaranth",
   @request=#<Evervault::Http::Request:0x00007f8b900b7d40 @api_key="API-KEY", @base_url="https://api.evervault.com/", @cage_run_url="https://cage.run/", @timeout=30>,
   @uuid="5b99011e-a64d-4af7-bf81-619c8cb8c67f">,
 "twilio-cage-explicit-salmon"=>
  #<Evervault::Models::Cage:0x00007f8b900b4348
   @name="twilio-cage-explicit-salmon",
   @request=#<Evervault::Http::Request:0x00007f8b900b7d40 @api_key="API-KEY", @base_url="https://api.evervault.com/", @cage_run_url="https://cage.run/", @timeout=30>,
   @uuid="55986772-4db7-4695-ba44-1b807290ddea">,
 "hello-cage-collective-aquamarine"=>
  #<Evervault::Models::Cage:0x00007f8b900b42f8
   @name="hello-cage-collective-aquamarine",
   @request=#<Evervault::Http::Request:0x00007f8b900b7d40 @api_key="API-KEY", @base_url="https://api.evervault.com/", @cage_run_url="https://cage.run/", @timeout=30>,
   @uuid="01691e76-691b-473e-aad5-44bf813ef146">,
 "twilio-cage-bored-scarlet"=>
  #<Evervault::Models::Cage:0x00007f8b900b42a8
   @name="twilio-cage-bored-scarlet",
   @request=#<Evervault::Http::Request:0x00007f8b900b7d40 @api_key="API-KEY", @base_url="https://api.evervault.com/", @cage_run_url="https://cage.run/", @timeout=30>,
   @uuid="dc056e8b-faf3-445b-9c95-0885b983c302">,
 "hello-cage-front-emerald"=>
  #<Evervault::Models::Cage:0x00007f8b900b4258
   @name="hello-cage-front-emerald",
   @request=#<Evervault::Http::Request:0x00007f8b900b7d40 @api_key="API-KEY", @base_url="https://api.evervault.com/", @cage_run_url="https://cage.run/", @timeout=30>,
   @uuid="a30295e6-91fc-4d1d-837c-ac4c9b87d02d">}
```

### Evervault::Models::Cage.run

Each Cage model exposes a `run` method, which allows you to run that particular Cage.

*Note*: this does not encrypt data before running the Cage.
```ruby
cage = Evervault.cage_list.cages[0]
cage.run({'name': 'testing'})
=> {"result"=>{"message"=>"Hello, world!", "details"=>"Please send an encrypted `name` parameter to show cage decryption in action"}, "runId"=>"5428800061ff"}
```

| Parameter | Type | Description |
| --------- | ---- | ----------- |
| data | Hash | Payload for the Cage |
| options | Hash | [Options for the Cage run](#Cage-Run-Options) |

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/evervault/evervault-ruby.

## Feedback

Questions or feedback? [Let us know](mailto:support@evervault.com).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
