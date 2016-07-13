require 'spec_helper'
require 'support/models'

describe DomainValidator do
  context "with valid domain" do
    valid_domains.each do |domain|
      user = User.new(:domain => domain)

      it "#{domain} should be valid" do
        expect(user).to be_valid
      end
    end
  end

  context "with invalid domain" do
    invalid_domains.each do |domain|
      user = User.new(:domain => domain)

      it "#{domain} should be invalid" do
        expect(user).to_not be_valid
      end
    end
  end

  describe "nil domain" do

    it "should not be valid when :allow_nil option is missing" do
      user = User.new(:domain => nil)
      expect(user).to_not be_valid
    end

    it "should be valid when :allow_nil option is true" do
      user = UserAllowsNil.new(:domain => nil)
      expect(user).to be_valid
    end

    it "should not be valid when :allow_nil option is false" do
      user = UserAllowsNilFalse.new(:domain => nil)
      expect(user).to_not be_valid
    end
  end

  describe "blank domain" do
    it "should not be valid when :allow_blank option is missing" do
      user = User.new(:domain => "   ")
      expect(user).to_not be_valid
    end

    it "should be valid when :allow_blank option is true" do
      user = UserAllowsBlank.new(:domain => "   ")
      expect(user).to be_valid
    end

    it "should not be valid when :allow_blank option is false" do
      user = UserAllowsBlankFalse.new(:domain => "   ")
      expect(user).to_not be_valid
    end
  end

  describe "error messages" do
    context "when the :message option is not defined" do
      subject { User.new :domain => "notadomain" }

      it "should add the default message" do
        subject.valid?
        expect(subject.errors[:domain]).to include "is invalid"
      end

      it "should prefer localized message" do
        with_error_translation(subject, :invalid_domain, "not right") do
          subject.valid?
          expect(subject.errors[:domain]).to include "not right"
        end
      end
    end

    context "when the :message option is defined" do
      subject { UserWithMessage.new :domain => "notadomain" }
      before { subject.valid? }

      it "should add the customized message" do
        expect(subject.errors[:domain]).to include "isn't quite right"
      end
    end

    context "when :verify_dns has a :message option" do
      subject { UserVerifyDNSMessage.new :domain => "a.com" }
      before { subject.valid? }

      it "should add the customized message" do
        expect(subject.errors[:domain]).to include "failed DNS check"
      end
    end

    context "when :verify_dns does not have a :message option" do
      subject { UserVerifyDNS.new :domain => "a.com" }

      it "should add the default message" do
        subject.valid?
        expect(subject.errors[:domain]).to include "does not have a valid DNS record"
      end

      it "should prefer localized message" do
        with_error_translation(subject, :missing_dns_record, "dns not right") do
          subject.valid?
          expect(subject.errors[:domain]).to include "dns not right"
        end
      end
    end

    context "when :verifiy_dns has a :same_ip_as option" do
      context "when :verfiy_dns does not have a message option" do
        context "with a domain without a DNS record" do
          subject { UserVerifyExampleDotCom.new :domain => "a.com" }

          it "should add the default message" do
            subject.valid?
            expect(subject.errors[:domain]).to include "does not have a valid DNS record"
          end

          it "should prefer localized message" do
            with_error_translation(subject, :missing_dns_record, "dns not right") do
              subject.valid?
              expect(subject.errors[:domain]).to include "dns not right"
            end
          end
        end

        context "with a domain that resolves to wrong ip" do
          subject { UserVerifyExampleDotCom.new :domain => "rubygems.org" }

          it "should add the default message" do
            subject.valid?
            expect(subject.errors[:domain]).to include "does not have a valid DNS record"
          end

          it "should prefer localized message" do
            with_error_translation(subject, :incorrect_dns_record, "dns not right") do
              subject.valid?
              expect(subject.errors[:domain]).to include "dns not right"
            end
          end
        end
      end

      context "when :verfiy_dns has a message option" do
        context "with a domain without a DNS record" do
          subject { UserVerifyExampleDotComWithMessage.new :domain => "a.com" }
          before { subject.valid? }

          it "should add the customized message" do
            expect(subject.errors[:domain]).to include "failed DNS check"
          end
        end

        context "with a domain that resolves to wrong ip" do
          subject { UserVerifyExampleDotComWithMessage.new :domain => "rubygems.org" }
          before { subject.valid? }

          it "should add the customized message" do
            expect(subject.errors[:domain]).to include "failed DNS check"
          end
        end
      end

      context "when :verfiy_dns has specific message options" do
        context "with a domain without a DNS record" do
          subject { UserVerifyExampleDotComWithSpecificMessages.new :domain => "a.com" }
          before { subject.valid? }

          it "should add the customized message" do
            expect(subject.errors[:domain]).to include "missing record"
          end
        end

        context "with a domain that resolves to wrong ip" do
          subject { UserVerifyExampleDotComWithSpecificMessages.new :domain => "rubygems.org" }
          before { subject.valid? }

          it "should add the invalid_record message" do
            expect(subject.errors[:domain]).to include "wrong ip"
          end
        end
      end

    end
  end

  describe "DNS check" do
    describe "an invalid domain" do
      it "should not perform a DNS check" do
        expect_any_instance_of(DomainValidator::DnsCheck).to_not receive(:has_record?)
        user = UserVerifyDNS.new(:domain => "notadomain")
        expect(user).to_not be_valid
      end
    end

    describe "a domain with a DNS record" do
      it "should be valid when :verify_dns is true" do
        user = UserVerifyDNS.new(:domain => "example.com")
        expect(user).to be_valid
      end

      it "should be valid when :verify_dns is false" do
        user = UserVerifyDNSFalse.new(:domain => "example.com")
        expect(user).to be_valid
      end

      it "should be valid when :verify_dns is undefined" do
        user = User.new(:domain => "example.com")
        expect(user).to be_valid
      end

      describe "when :verifiy_dns has :same_ip_as option" do
        it "should be valid when domain resolves to same ip" do
          user = UserVerifyExampleDotCom.new(:domain => "www.example.com")
          expect(user).to be_valid
        end

        it "should not be valid domain resolves to different ip" do
          user = UserVerifyExampleDotCom.new(:domain => "rubygems.org")
          expect(user).not_to be_valid
        end
      end
    end

    describe "a domain without a DNS record" do
      it "should not be valid when :verify_dns is true" do
        user = UserVerifyDNS.new(:domain => "a.com")
        expect(user).to_not be_valid
      end

      it "should be valid when :verify_dns is false" do
        user = UserVerifyDNSFalse.new(:domain => "a.com")
        expect(user).to be_valid
      end

      it "should be valid when :verify_dns is undefined" do
        user = User.new(:domain => "a.com")
        expect(user).to be_valid
      end

      it "should not be valid when :verify_dns has :same_ip_as option" do
        user = UserVerifyExampleDotCom.new(:domain => "a.com")
        expect(user).not_to be_valid
      end
    end
  end

end
