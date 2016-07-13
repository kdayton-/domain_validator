require "resolv"

module DomainValidator
  class DnsCheck

    def self.detect_issues(domain, options = {})
      address = Resolv::DNS.new.getaddress(domain)

      if options[:same_ip_as]
        other_domain = options[:same_ip_as]
        other_domain = other_domain.call if other_domain.respond_to?(:call)
        other_address = Resolv::DNS.new.getaddress(other_domain)
        return :incorrect_dns_record if other_address != address
      end

      return nil
    rescue Resolv::ResolvError => e
      return :missing_dns_record
    end

  end
end
