# frozen_string_literal: true

RSpec.describe Evervault::Utils::ValidationUtils do
  describe '#validate_app_uuid_and_api_key' do
    it 'should raise an error if the app_uuid is nil' do
      expect do
        Evervault::Utils::ValidationUtils.validate_app_uuid_and_api_key(nil, 'test')
      end.to raise_error(Evervault::Errors::EvervaultError)
    end

    it 'should raise an error if the api_key is nil' do
      expect do
        Evervault::Utils::ValidationUtils.validate_app_uuid_and_api_key('test', nil)
      end.to raise_error(Evervault::Errors::EvervaultError)
    end

    it 'should raise an error if the api_key does not belong to the app' do
      expect do
        Evervault::Utils::ValidationUtils.validate_app_uuid_and_api_key('app_28807f2a6bb2',
                                                                        'ev:key:1:random:sZ4zvj:9iZ95W')
      end.to raise_error(Evervault::Errors::EvervaultError)
    end

    it 'should not raise an error if the App ID and the scoped API key are valid' do
      Evervault::Utils::ValidationUtils.validate_app_uuid_and_api_key('app_28807f2a6bb1',
                                                                      'ev:key:1:random:sZ4zvj:9iZ95W')
    end

    it 'should not raise an error if the App ID and the legacy API key are valid' do
      Evervault::Utils::ValidationUtils.validate_app_uuid_and_api_key('app_28807f2a6bb1', 'some_api_key_material')
    end
  end
end
