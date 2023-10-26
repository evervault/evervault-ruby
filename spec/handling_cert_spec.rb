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
  let(:valid_cert) do
"-----BEGIN CERTIFICATE-----
MIIF/TCCA+WgAwIBAgIUVkGvj1cTGx1Qvg3DNI7Ffy+HA8cwDQYJKoZIhvcNAQEL
BQAwgY0xCzAJBgNVBAYTAklFMREwDwYDVQQIDAhMZWluc3RlcjEPMA0GA1UEBwwG
RHVibGluMRIwEAYDVQQKDAlFdmVydmF1bHQxHDAaBgNVBAMME3JlbGF5LmV2ZXJ2
YXVsdC5jb20xKDAmBgkqhkiG9w0BCQEWGWVuZ2luZWVyaW5nQGV2ZXJ2YXVsdC5j
b20wHhcNMjIwMjE4MTUzNzQ2WhcNMzIwMjE2MTUzNzQ2WjCBjTELMAkGA1UEBhMC
SUUxETAPBgNVBAgMCExlaW5zdGVyMQ8wDQYDVQQHDAZEdWJsaW4xEjAQBgNVBAoM
CUV2ZXJ2YXVsdDEcMBoGA1UEAwwTcmVsYXkuZXZlcnZhdWx0LmNvbTEoMCYGCSqG
SIb3DQEJARYZZW5naW5lZXJpbmdAZXZlcnZhdWx0LmNvbTCCAiIwDQYJKoZIhvcN
AQEBBQADggIPADCCAgoCggIBALdxSWUs2Rw5C3o/sqyZHX4bdrdpGd/jI8D5mU+F
6pPAJTT1KFo9pL0V7Qf2fPocOUkwGje1nctmkiZ0oMDLaxQabQXuFx1mDpa4lr2O
dpnDVXzh9d06Lin87vrp+SDyVxudr3/jP2Yw3PBcxPfDdIEsvA8deXAAZHAXgmuR
DKcYXh8lPXrH0wd2M2UQK+8xprU3qLNlu30GbaEx0CCHcRSkxtpkAHmveiVxnof5
pn7IIlbklr/X7vEgpm+d8VIB0/oJMKqkWVWCWDlATIcZXtcN0KTuEpiMj0QMlo4i
xw8w8BIURDn84ApWljbcrqJ9ffn8B/JgFptsoWUjg2W5nfIxVujbVkvBPQ7cgu1a
hV/JQtWcR/jGm1Qse1m8HxlK0bnQowOrtkJE/JL6Gax6ujyAm7mhAVCRSWIv/SnK
d4w6uTAil8EAGiID23r822OG59wjiKiZVIXGVoQFzzHqJ+nYkLVBu6h+cs+V8DnL
DYBkpj+8lBJwTrh+nMG1OeX6Jok0007x7PZUmA7bYjBFsU0HGpsmRin4Iu3Ufz0Z
ANXn+SlxQ1ZjIeyB/bRYHCnrtPPCAJBBRDLX32uwVVUSlj+66DyGca5okGgnTv0V
UxSEP9lvClL9wohTtehLejAHXEhI+2ZO07tfCB9wh8CN56WAYtgjSSyP1XRPA9Mw
jYORAgMBAAGjUzBRMB0GA1UdDgQWBBRCZd5nf33sL/8r7DKmxq1H88T2bDAfBgNV
HSMEGDAWgBRCZd5nf33sL/8r7DKmxq1H88T2bDAPBgNVHRMBAf8EBTADAQH/MA0G
CSqGSIb3DQEBCwUAA4ICAQAXNMhOMws4yv7NTxjr1UAchMIqX0EzyR/pWy2DmToj
NPriE+vSg6ER83cZuaNxrG9xVhICjQ2mcaxK/G8CH3WiIFGCvBy7RoPberTOIVWU
0C051mo9M0VY0ktimErnNrzjvQLfDHQZixWjvPGwut2toZCxujJ4x0CI3CaejrVU
sapRsxL5E/Qh3CKBEtfupxBb6+2T/eS/4aSCPst2kuT91prFStamSYL0CWpQ7G7Q
A8FbnrwO3NrMTB6IshQg9LjK4Z+hB+YBKzVMzm5jwMo2JfXmQbE5dh4fXfPsaCxp
X2zfsxQCzn1bfDzh64o7UVDk7LCUp0758muPPdBMfV54KuH6/JIwEADK6okA3+lK
dHcaoAYTfN8ysroDrjmvD0f0MB2OaKnQL2l5QQXxKmtIeLMMEcn8lR81k3XsBlxM
VWAmR50CrHX0g3z/KfV1aVyxfmcW1nw9MNWP3+2Pvp2flLHZ+b9eSWZd500Sh7Od
cRHNPrXUABtK/dbNKHUiQV2Ql1yej99cCLoqD+GT5euEe0alwtYr1YRMxP47zh/Z
Ch3hgrnbD4OG9ssz4ij8b+qxdfMTng/33OsMILyYmXi8NRFoJiAMlpYlltPub8Xu
Gu2q1tR9TzpXYZ+Yv1/YUApnryI8Dbd2azpYW4obHvGOFS1bxNQ3waqmx51ig45S
6w==
-----END CERTIFICATE-----"
  end
  let(:expired_cert) do
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
    Evervault.app_id = "app_uuid"
    Evervault.api_key = "testing" 
  end

  describe "test_cert_is_valid" do
    it "detects cert is expired" do
      stub_request(:get, "https://ca.evervault.com/").
        with(
          headers: {
            "Accept"=>"application/json",
            "Accept-Encoding"=>"gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
            "Acceptencoding"=>"gzip, deflate",
            "Api-Key"=>"testing",
            "Content-Type"=>"application/json",
            "User-Agent"=>"evervault-ruby/#{Evervault::VERSION}"
          }).
        to_return({ status: 200, body: valid_cert })
      allow(Time).to receive(:now).and_return(Time.parse('2022-06-06'))
      intercept.setup()
      expect(intercept.is_certificate_expired()).to be false
    end
  end

  describe "test_cert_is_expired" do
    it "detects cert is expired" do
      stub_request(:get, "https://ca.evervault.com/").
        with(
          headers: {
            "Accept"=>"application/json",
            "Accept-Encoding"=>"gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
            "Acceptencoding"=>"gzip, deflate",
            "Api-Key"=>"testing",
            "Content-Type"=>"application/json",
            "User-Agent"=>"evervault-ruby/#{Evervault::VERSION}"
          }).
        to_return({ status: 200, body: expired_cert})
      intercept.setup()
      expect(intercept.is_certificate_expired()).to be true
    end
  end

  describe "test_not_available_cert_is_not_expired" do
    it "detects cert is expired" do
      stub_request(:get, "https://ca.evervault.com/").
        with(
          headers: {
            "Accept"=>"application/json",
            "Accept-Encoding"=>"gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
            "Acceptencoding"=>"gzip, deflate",
            "Api-Key"=>"testing",
            "Content-Type"=>"application/json",
            "User-Agent"=>"evervault-ruby/#{Evervault::VERSION}"
          }).
        to_return({ status: 200, body: ""})
      expect { intercept.setup() }.to raise_error(Evervault::Errors::EvervaultError)
      expect(intercept.is_certificate_expired()).to be false
    end
  end
end
