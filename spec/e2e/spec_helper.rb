require "bundler/setup"
require "evervault"
require "rspec"
require "pry"
require 'webmock/rspec'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status_e2e"

  WebMock.enable_net_connect!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end