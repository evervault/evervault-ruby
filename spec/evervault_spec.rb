require_relative "spec_helper"
require "webmock"

RSpec.describe Evervault do
  let(:public_key) { "Ax1NYOSqswFgsRoLFTac7eOvRu7h3GuLmUPKlHpOqsFA" }
  let(:request) do
    Evervault::Http::Request.new(
      timeout: 30,
      api_key: "testing",
    )
  end
  let(:intercept) do
    Evervault::Http::RequestIntercept.new(
      request: request, 
      ca_host: "https://ca.evervault.com",
      api_key: "testing", 
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
  let(:crypto_client) do 
    Evervault::Crypto::Client.new(request_handler: request_handler, curve: "secp256k1") 
  end
  let(:cert) do
    '-----BEGIN CERTIFICATE-----
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
-----END CERTIFICATE-----'
  end

  before :each do 
    Evervault.api_key = "testing" 
    allow(Time).to receive(:now).and_return(Time.parse('2022-06-06'))
  end

  describe "encrypt" do
    before do
      allow(request_handler).to receive(:get).with("cages/key").and_return({ "ecdhKey" => public_key })
      allow(Evervault::Http::RequestHandler).to receive(:new).and_return(request_handler)

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
      to_return({ status: 200, body: cert, headers: {} })
    end

    it "encrypts strings as ev string type" do
      encrypted_data = Evervault.encrypt(1)
      expect(is_evervault_string(encrypted_data, "number")).to be true
    end

    it "encrypts numbers as ev number type" do
      encrypted_data = Evervault.encrypt(true)
      expect(is_evervault_string(encrypted_data, "boolean")).to be true
    end

    it "encrypts booleans as ev boolean type" do
      encrypted_data = Evervault.encrypt("testing")
      expect(is_evervault_string(encrypted_data, "string")).to be true
    end

    it "encrypts arrays" do
      encrypted_data = Evervault.encrypt(["testing", "encrypting", "array"])
      expect(encrypted_data.length).to be 3
      for item in encrypted_data
        expect(is_evervault_string(item, "string")).to be true
      end
    end

    it "encrypts hashes" do
      test_payload = {
        "name": "testname",
        "age": 20,
        "array": ["team1", 1],
        "dict": {"subname": "subtestname", "subnumber": 2},
      }
      encrypted_data = Evervault.encrypt(test_payload)
      expect(encrypted_data).to_not equal({"name": "testname"})
      expect(encrypted_data.key? 'name'.to_sym).to be true
      expect(encrypted_data["dict".to_sym].class.to_s).to eq "Hash"
      expect(is_evervault_string(encrypted_data["dict".to_sym]["subnumber".to_sym], "number")).to be true
    end

    it "throws exception on unsupported type" do
      class MyTestClass
        @x = 5
      end
      test_instance = MyTestClass.new()
      list = ["a", 1, test_instance]
      expect { Evervault.encrypt(test_instance) }.to raise_error(Evervault::Errors::UnsupportedEncryptType)
      expect { Evervault.encrypt(list) }.to raise_error(Evervault::Errors::UnsupportedEncryptType)
    end

  end

  def is_evervault_string(data, type)
    parts = data.split(":")
    parts_length = parts.length
    if parts_length < 6
        return false
    elsif type == "string"
        return parts_length == 6
    elsif type != "string" && parts_length != 7
        return false
    elsif type != parts[2]
        return false
    else
      return true
    end
  end

  describe "run" do
    before do 
      allow(Evervault::Http::RequestHandler).to receive(:new).and_return(request)
      stub_request(:post, "https://cage.run/testing-cage").with(
        headers: {
          "Accept"=>"application/json",
          "Accept-Encoding"=>"gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Acceptencoding"=>"gzip, deflate",
          "Api-Key"=>"testing",
          "Content-Type"=>"application/json",
          "User-Agent"=>"evervault-ruby/#{Evervault::VERSION}"
          },
          body: {
            name: "testing"
          }.to_json
        )
           .to_return({ status: status, body: response.to_json }) 
    end

    context "success" do
      let(:response) { { "result"=>{"message"=>"Hello, world!", "details"=>"Please send an encrypted `name` parameter to show cage decryption in action"}, "runId"=>"5428800061ff" } }
      let(:status) { 200 }

      it "makes a post request to the cage run API" do
        Evervault.run("testing-cage", { name: "testing" })
        assert_requested(:post, "https://cage.run/testing-cage", body: { name: "testing" }, times: 1)
      end
    end

    context "failure" do
      let(:response) { { "Error" => "Bad request"} }
      let(:status) { 400 }

      it "makes a post request to the cage run API and maps the error" do
        expect { Evervault.run("testing-cage", { name: "testing" }) }.to raise_error(Evervault::Errors::BadRequestError)
        assert_requested(:post, "https://cage.run/testing-cage", body: { name: "testing" }, times: 1)
      end
    end
  end

  describe "run_with_options" do
    before do
      allow(Evervault::Http::RequestHandler).to receive(:new).and_return(request)
      stub_request(:post, "https://cage.run/testing-cage").with(
        headers: {
          "Accept"=>"application/json",
          "Accept-Encoding"=>"gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Acceptencoding"=>"gzip, deflate",
          "Api-Key"=>"testing",
          "Content-Type"=>"application/json",
          "User-Agent"=>"evervault-ruby/#{Evervault::VERSION}",
          "x-async"=>"true"
          },
          body: {
            name: "testing"
          }.to_json
        )
        .to_return({ status: status, body: response.to_json })
    end

    context "success with options" do
      let(:response) { { "result" =>{ "status" => "queued" } } }
      let(:status) { 202 }

      it "makes an async cage run request" do
        Evervault.run("testing-cage", { name: "testing" }, { async: true })
        assert_requested(:post, "https://cage.run/testing-cage", body: { name: "testing" }, times: 1)
      end
    end
  end

  describe "encrypt_and_run" do
    before do 
      allow(Evervault::Http::RequestHandler).to receive(:new).and_return(request)
      allow_any_instance_of(Evervault::Crypto::Client).to receive(:encrypt).and_return({ name: "encrypted" })
      stub_request(:post, "https://cage.run/testing-cage").with(
        headers: {
          "Accept"=>"application/json",
          "Accept-Encoding"=>"gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Acceptencoding"=>"gzip, deflate",
          "Api-Key"=>"testing",
          "Content-Type"=>"application/json",
          "User-Agent"=>"evervault-ruby/#{Evervault::VERSION}"
        },
        body: { name: "encrypted" }.to_json
      ).to_return({ status: status, body: response.to_json, headers: response_headers }) 
    end

    context "success" do
      let(:response) { { "result"=>{"message"=>"Hello, world!", "details"=>"Please send an encrypted `name` parameter to show cage decryption in action"}, "runId"=>"5428800061ff" } }
      let(:status) { 200 }
      let(:response_headers) { {} }

      it "makes a post request to the cage run API" do
        Evervault.encrypt_and_run("testing-cage", { name: "testing" })
        assert_requested(:post,  "https://cage.run/testing-cage", times: 1)
      end
    end

    context "forbidden-ip" do
      let(:response) { { "Error" => "An error occurred" } }
      let(:status) { 403 }
      let(:response_headers) { { "x-evervault-error-code": "forbidden-ip-error" } }

      it "makes a post request to the cage run API and maps the error" do
        expect { Evervault.encrypt_and_run("testing-cage", { name: "testing" }) }.to raise_error(Evervault::Errors::ForbiddenIPError)
        assert_requested(:post,  "https://cage.run/testing-cage", times: 1)
      end
    end

    context "forbidden" do
      let(:response) { { "Error" => "An error occurred"} }
      let(:status) { 403 }
      let(:response_headers) { {} }

      it "makes a post request to the cage run API and maps the error" do
        expect { Evervault.encrypt_and_run("testing-cage", { name: "testing" }) }.to raise_error(Evervault::Errors::AuthenticationError)
        assert_requested(:post,  "https://cage.run/testing-cage", times: 1)
      end
    end
  end

  describe "encrypt_and_run_with_options" do
    before do
      allow(Evervault::Http::RequestHandler).to receive(:new).and_return(request)
      allow_any_instance_of(Evervault::Crypto::Client).to receive(:encrypt).and_return({ name: "encrypted" })
      stub_request(:post, "https://cage.run/testing-cage").with(
        headers: {
          "Accept"=>"application/json",
          "Accept-Encoding"=>"gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Acceptencoding"=>"gzip, deflate",
          "Api-Key"=>"testing",
          "Content-Type"=>"application/json",
          "User-Agent"=>"evervault-ruby/#{Evervault::VERSION}",
          "x-async"=>"true"
          },
          body: { name: "encrypted" }.to_json
        )
        .to_return({ status: status, body: response.to_json })
    end

    context "success with options" do
      let(:response) { { "result" =>{ "status" => "queued" } } }
      let(:status) { 202 }

      it "makes an async cage run request" do
        Evervault.encrypt_and_run("testing-cage", { name: "testing" }, { async: true })
        assert_requested(:post, "https://cage.run/testing-cage", body: { name: "encrypted" }, times: 1)
      end
    end
  end

  describe "run_with_intercept_domain" do
    before do

      allow(Evervault::Http::RequestHandler).to receive(:new).and_return(request)
      allow_any_instance_of(Evervault::Crypto::Client).to receive(:encrypt).and_return({ name: "encrypted" })
      stub_request(:post, "https://cage.run/testing-cage").with(
        headers: {
          "Accept"=>"application/json",
          "Accept-Encoding"=>"gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Acceptencoding"=>"gzip, deflate",
          "Api-Key"=>"testing",
          "Content-Type"=>"application/json",
          "User-Agent"=>"evervault-ruby/#{Evervault::VERSION}"
        },
        body: { name: "encrypted" }.to_json
      ).to_return({ status: status, body: response.to_json, headers: response_headers }) 
    end

    context "success" do
      let(:response) { { "result"=>{"message"=>"Hello, world!", "details"=>"Please send an encrypted `name` parameter to show cage decryption in action"}, "runId"=>"5428800061ff" } }
      let(:status) { 200 }
      let(:response_headers) { {} }

      it "makes a post request to the cage run API" do
        Evervault.encrypt_and_run("testing-cage", { name: "testing" })
        assert_requested(:post,  "https://cage.run/testing-cage", times: 1)
      end
    end
  end

  it "has a version number" do
    expect(Evervault::VERSION).not_to be nil
  end
end
