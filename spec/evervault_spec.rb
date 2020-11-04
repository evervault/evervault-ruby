require_relative "spec_helper"
require "webmock"

RSpec.describe Evervault do
  let(:key_pair) { OpenSSL::PKey::RSA.generate(1024) }
  let(:public_key) { key_pair.public_key }
  let(:private_key) { key_pair.private_key }
  let(:request) do 
    Evervault::Http::Request.new(
      api_key: "testing", 
      base_url: "https://api.evervault.com", 
      cage_run_url: "https://cage.run/", 
      timeout: 30
    ) 
  end
  let(:crypto_client) do 
    Evervault::Crypto::Client.new(request: request) 
  end

  before :each do 
    Evervault.api_key = "testing" 
  end

  describe "encrypt" do

    before do
      allow(request).to receive(:get).with("cages/key").and_return({ "key" => public_key.to_s })
      allow(Evervault::Http::Request).to receive(:new).and_return(request)
    end

    it "encrypts hashes and observes their structure" do
      encrypted_data = Evervault.encrypt({ name: "testing", other_thing: "hello" })
      expect(encrypted_data).to_not equal({ name: "testing", other_thing: "hello" })
      expect(encrypted_data[:name]).to_not be(nil)
      expect(encrypted_data[:other_thing]).to_not be(nil)
    end

    it "encrypts strings" do
      encrypted_data = Evervault.encrypt("testing")
      expect(encrypted_data).to_not equal("testing")
    end
  end

  describe "run" do
    before do 
      allow(Evervault::Http::Request).to receive(:new).and_return(request)
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

  describe "encrypt_and_run" do
    before do 
      allow(Evervault::Http::Request).to receive(:new).and_return(request)
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
      ).to_return({ status: status, body: response.to_json }) 
    end

    context "success" do
      let(:response) { { "result"=>{"message"=>"Hello, world!", "details"=>"Please send an encrypted `name` parameter to show cage decryption in action"}, "runId"=>"5428800061ff" } }
      let(:status) { 200 }

      it "makes a post request to the cage run API" do
        Evervault.encrypt_and_run("testing-cage", { name: "testing" })
        assert_requested(:post,  "https://cage.run/testing-cage", times: 1)
      end
    end

    context "failure" do
      let(:response) { { "Error" => "Bad request"} }
      let(:status) { 400 }

      it "makes a post request to the cage run API and maps the error" do
        expect { Evervault.encrypt_and_run("testing-cage", { name: "testing" }) }.to raise_error(Evervault::Errors::BadRequestError)
        assert_requested(:post,  "https://cage.run/testing-cage", times: 1)
      end
    end
  end

  it "has a version number" do
    expect(Evervault::VERSION).not_to be nil
  end
end
