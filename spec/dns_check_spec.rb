require 'spec_helper'

# I hope no one registers this
NOT_A_REAL_DOMAIN = "zjnajkndsjkangunausgnasngiuansiugnaiusngansjkgnaskjnaksjdn.com"

module DomainValidator
  describe DnsCheck do
    describe '#detect_issues' do

      context "given a domain without a DNS record" do
        it "should return :missing_dns_record" do
          expect( DnsCheck.detect_issues(NOT_A_REAL_DOMAIN) ).to eq(:missing_dns_record)
        end
      end

      context "given a domain with a DNS record not matching reference domain" do
        it "should return :incorrect_dns_record" do
          result = DnsCheck.detect_issues("example.com", :same_ip_as => 'rubygems.org')
          expect(result).to eq(:incorrect_dns_record)
        end
      end

      context "given a domain with a DNS record matching reference domain" do
        it "should return nil" do
          result = DnsCheck.detect_issues("example.com", :same_ip_as => 'www.example.com')
          expect(result).to eq(nil)
        end
      end

      context "given a domain with a DNS record" do
        it "should return nil" do
          expect( DnsCheck.detect_issues("example.com") ).to eq(nil)
        end
      end

      it "supports callable as :same_ip_as option" do
        result = DnsCheck.detect_issues("example.com", :same_ip_as => -> { 'www.example.com' })
        expect(result).to eq(nil)
      end

    end
  end
end
