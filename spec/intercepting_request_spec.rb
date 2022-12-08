require_relative "spec_helper"
require "webmock"

RSpec.describe Evervault do 
  describe "NetHTTPOverride" do
    context "should_decrypt" do
      it "returns true if the domain matches the decryption domain" do
        NetHTTPOverride.add_get_decryption_domains_func(lambda { ["example.com"] })
        expect(NetHTTPOverride.should_decrypt("example.com")).to eq(true)
      end

      it "returns true if the domain does is an allowed subdomain" do
        NetHTTPOverride.add_get_decryption_domains_func(lambda { ["*.example.com"] })
        expect(NetHTTPOverride.should_decrypt("bar.example.com")).to eq(true)
        expect(NetHTTPOverride.should_decrypt("foo.bar.example.com")).to eq(true)
      end

      it "returns false if the domain does not match the decryption domain" do
        NetHTTPOverride.add_get_decryption_domains_func(lambda { ["example.com"] })
        expect(NetHTTPOverride.should_decrypt("otherexample.com")).to eq(false)
      end
    end
  end
end