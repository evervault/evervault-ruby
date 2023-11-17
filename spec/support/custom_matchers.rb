# frozen_string_literal: true

RSpec.configure do |_config|
  RSpec::Matchers.define :be_encrypted do |type|
    match do |actual|
      type_matches = type.nil? || actual&.include?(":#{type}:")
      actual&.start_with?('ev:') && type_matches
    end

    failure_message do |actual|
      "expected '#{actual}' to be an encrypted #{type || 'string'}"
    end
  end
end
