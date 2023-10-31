require 'simplecov'
SimpleCov.start do
  add_filter '/spec/' 
end

require 'dotenv'
Dotenv.load

require "bundler/setup"
require "evervault"
require "rspec"
require "pry"
require 'webmock/rspec'

# require all support files
Dir["./spec/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.include RequestMocks

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable outbound network connections
  WebMock.disable_net_connect!

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
