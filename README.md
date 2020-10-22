# Evervault
<p align="center">
  <img src="res/logo.svg">
</p>

<p align="center">
  <a href="https://github.com/evervault/evervault-ruby/actions?query=workflow%3Aevervault-unit-tests"><img alt="Evervault unit tests status" src="https://github.com/evervault/evervault-ruby/workflows/evervault-unit-tests/badge.svg"></a>
</p>


## Getting Started
Ruby SDK for [Evervault](https://evervault.com)
### Prerequisites

To get started with the Evervault Ruby SDK, you will need to have created a team on the evervault dashboard.

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

## Setup

Evervault can be initialized as a singleton throughout the lifecycle of your application.
```ruby
require "evervault"

# Initialize the client with your team's api key
Evervault.api_key = <YOUR-API-KEY>

# Encrypt your data and run a cage
result = Evervault.encrypt_and_run(<CAGE-NAME>, { hello: 'World!' })
```

It's recommended to re-use your Evervault client, to prevent additional overhead of loading keys at runtime, so the singleton pattern should be the go-to pattern for most use-cases.

However, if you'd prefer to initialize different clients at different times, for example, if you have multiple teams and need to switch context, you can simply create a client:
```ruby
require "evervault"

# Initialize the client with your team's api key
evervault = Evervault::Client.new(api_key: <YOUR-API-KEY>)

# Encrypt your data and run a cage
result = evervault.encrypt_and_run(<CAGE-NAME>, { hello: 'World!' })
```

## API Reference

### Evervault.encrypt

Encrypt lets you encrypt data for use in any of your evervault cages. You can use it to store encrypted data to be used in a cage at another time.

```ruby
Evervault.encrypt(data = Hash | String)
```

| Parameter | Type | Description |
| --------- | ---- | ----------- |
| data | Hash or String | Data to be encrypted |

### Evervault.run

Run lets you invoke your evervault cages with a given payload.

```ruby
Evervault.run(cage_name = String, data = Hash)
```

| Parameter | Type | Description |
| --------- | ---- | ----------- |
| cageName | String | Name of the cage to be run |
| data | Hash | Payload for the cage |

### Evervault.encrypt_and_run

Encrypt your data and use it as the payload to invoke the cage.

```ruby
Evervault.encrypt_and_run(cage_name = String, data = Hash)
```

| Parameter | Type | Description |
| --------- | ---- | ----------- |
| cageName | String | Name of the cage to be run |
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

Return a `CageList` object, containing a list of your team's cages

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

Converts a list of cages to a hash with keys of CageName => Cage Model

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

Each Cage model exposes a `run` method, which allows you to run that particular cage.

*Note*: this does not encrypt data before running the cage
```ruby
cage = Evervault.cage_list.cages[0]
cage.run({'name': 'testing'})
=> {"result"=>{"message"=>"Hello, world!", "details"=>"Please send an encrypted `name` parameter to show cage decryption in action"}, "runId"=>"5428800061ff"}
```

| Parameter | Type | Description |
| --------- | ---- | ----------- |
| data | Hash | Payload for the cage |

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/evervault/evervault-ruby.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
