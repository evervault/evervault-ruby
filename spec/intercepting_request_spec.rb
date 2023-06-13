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

      it "returns true if the domain is given in a domain and subdomain matcher" do
        NetHTTPOverride.add_get_decryption_domains_func(lambda { ["*example.com"] })
        expect(NetHTTPOverride.should_decrypt("example.com")).to eq(true)
      end

      it "returns true if a subdomain is given in a domain and subdomain matcher" do
        NetHTTPOverride.add_get_decryption_domains_func(lambda { ["*example.com"] })
        expect(NetHTTPOverride.should_decrypt("test.example.com")).to eq(true)
      end
      
      it "returns false if a malicious domain that has the domain and subdomain matcher as a suffix" do
        NetHTTPOverride.add_get_decryption_domains_func(lambda { ["*example.com"] })
        expect(NetHTTPOverride.should_decrypt("malicious_example.com")).to eq(false)
      end
    end
  end
end
