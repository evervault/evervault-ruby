# frozen_string_literal: true

require_relative 'lib/evervault/version'

Gem::Specification.new do |spec|
  spec.name          = 'evervault'
  spec.version       = Evervault::VERSION
  spec.authors       = ['Evervault']
  spec.email         = 'support@evervault.com'
  spec.summary       = 'Ruby SDK to run Evervault'
  spec.homepage      = 'https://evervault.com'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/evervault/evervault-ruby'

  spec.add_dependency 'faraday', ['>= 2.0', '< 3.0']

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'dotenv'
  spec.add_development_dependency 'simplecov'
end
