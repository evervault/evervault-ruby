require_relative "spec_helper"
require "webmock"

RSpec.describe Evervault do
  let(:request) do
    Evervault::Http::Request.new(
      timeout: 30,
      app_uuid: "app_test",
      api_key: "testing"
    )
  end
  let(:intercept) do
    Evervault::Http::RequestIntercept.new(
      request: request, 
      ca_host: "https://ca.evervault.com",
      api_key: "testing", 
      base_url: "https://api.evervault.com/",
      relay_url: "https://relay.evervault.com:8443",
    )
  end
  let(:request_handler) do
    Evervault::Http::RequestHandler.new(
      request: request,
      base_url: "https://api.evervault.com/", 
      cage_run_url: "https://cage.run/", 
      cert: intercept
    ) 
  end
  let(:cert) do
"-----BEGIN CERTIFICATE-----
MIIDgzCCAmugAwIBAgIUEL9SyDnNVvLXq8opJM2nrLgoFpgwDQYJKoZIhvcNAQEL
BQAwUTELMAkGA1UEBhMCSUUxEzARBgNVBAgMCkR1YmxpbiBDby4xDzANBgNVBAcM
BlN3b3JkczEcMBoGA1UECgwTRGVmYXVsdCBDb21wYW55IEx0ZDAeFw0wODEyMjQw
ODE2MDhaFw0wOTAxMDMwODE2MDhaMFExCzAJBgNVBAYTAklFMRMwEQYDVQQIDApE
dWJsaW4gQ28uMQ8wDQYDVQQHDAZTd29yZHMxHDAaBgNVBAoME0RlZmF1bHQgQ29t
cGFueSBMdGQwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDoCOTOgSCf
wsbSefJQwu51Krbz9jTFic4tbaM3B2BROtqAxDHdDIE5HQ1nhuZ06XyL9aLjDI2J
9WOWTkN/iXh0XcUJmIlBgErs7EQbIeXjO6pTa4S+tjBtbnVF8Aaz2Bj2AuD4O9VJ
AP8HmS654dOWjhqnEsRbv9IJo+ccvy699afWsoYePILZOJmoeiGXvQ/ZTbj4cYDx
CxZOkYK5HK3Zv0VfK5B+hsz3buuijkPdIG46o6DAE2nmNjrTxaz1/BuiWDEvC8RK
8NOY92LoiDMSxWVP2/UDDsKqWlGS7KmpdmIx1ndH6eYyYJut5xvLE7vlkr6s96O2
AN5EQ28oQNNHAgMBAAGjUzBRMB0GA1UdDgQWBBQDqdmoCx8KJdc6giTS69YtlAsc
vDAfBgNVHSMEGDAWgBQDqdmoCx8KJdc6giTS69YtlAscvDAPBgNVHRMBAf8EBTAD
AQH/MA0GCSqGSIb3DQEBCwUAA4IBAQAiBFVUOI07QOVbMAMWNk5D3L308wx6avqI
4FY6aSfmIGp898ab6L3XOrz54ztOuIyjdUaQ8/U1yFGxTBe66zPKDyorHm0a+kNp
2h5luIXRsm6IZrpGblO7CD+ZzYZ04qWkHgugLSieKhO3GVKObdkdfnJIf2O5KW7j
PulHfTQ3MNd/qXhOBNUXgI0rcWeI5xGKzAVWRoiAcAHU9UmNrunVg9CQMh0i6nYA
i7xFTBvY5QrZGK/Y6mEAdGCRoGusOputz1MHn721sIyH5DtCAMXdJ/s94Ki7m557
qLZdvkgx0KBRnP/JPZ55VgjZ8ipH9+SGxsZeTg9sX6nw+x/Plncz
-----END CERTIFICATE-----"
  end
  before :each do 
    Evervault.app_uuid = "app_test"
    Evervault.api_key = "testing" 
  end

  describe "expired_cert" do
    before :each do
      allow(intercept).to receive(:is_certificate_expired).and_return(true)
      allow(intercept).to receive(:setup).and_return(true)
    end

    it "is updated by get" do
      stub_request(:get, "https://api.evervault.com/cages").
         with(
           headers: {
          'Accept'=>'application/json',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Acceptencoding'=>'gzip, deflate',
          'Api-Key'=>'testing',
          'Content-Type'=>'application/json',
          'User-Agent'=>"evervault-ruby/#{Evervault::VERSION}"
           }).
         to_return(status: 200, body: "{}", headers: {})
      expect(intercept).to receive(:setup)
      request_handler.get("cages")
    end

    it "is updated by post" do
      stub_request(:post, "https://api.evervault.com/cages").
         with(
           headers: {
          'Accept'=>'application/json',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Acceptencoding'=>'gzip, deflate',
          'Api-Key'=>'testing',
          'Content-Type'=>'application/json',
          'User-Agent'=>"evervault-ruby/#{Evervault::VERSION}"
           }).
         to_return(status: 200, body: "{}", headers: {})
      expect(intercept).to receive(:setup)
      request_handler.post("cages", {})
    end

    it "is updated by put" do
      stub_request(:put, "https://api.evervault.com/cages").
         with(
           headers: {
          'Accept'=>'application/json',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Acceptencoding'=>'gzip, deflate',
          'Api-Key'=>'testing',
          'Content-Type'=>'application/json',
          'User-Agent'=>"evervault-ruby/#{Evervault::VERSION}"
           }).
         to_return(status: 200, body: "{}", headers: {})
      expect(intercept).to receive(:setup)
      request_handler.put("cages", {})
    end

    it "is updated by delete" do
      stub_request(:delete, "https://api.evervault.com/cages").
         with(
           headers: {
          'Accept'=>'application/json',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Acceptencoding'=>'gzip, deflate',
          'Api-Key'=>'testing',
          'Content-Type'=>'application/json',
          'User-Agent'=>"evervault-ruby/#{Evervault::VERSION}"
           }).
         to_return(status: 200, body: "{}", headers: {})
      expect(intercept).to receive(:setup)
      request_handler.delete("cages", {})
    end
  end
end
