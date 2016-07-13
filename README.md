# DomainValidator

[![Build Status](https://travis-ci.org/kyledayton/domain_validator.png?branch=master)](https://travis-ci.org/kyledayton/domain_validator)
[![Code Climate](https://codeclimate.com/github/kyledayton/domain_validator.png)](https://codeclimate.com/github/kyledayton/domain_validator)

Adds a DomainValidator to ActiveModel, allowing for easy validation of FQDNs


## Installation

Add this line to your application's Gemfile:

    gem 'domain_validator'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install domain_validator

## Usage

Add a domain validation to your ActiveModel enabled class

```ruby
class User < ActiveRecord::Base
  attr_accessible :domain
  validates :domain, :domain => true
end
```

DomainValidator can also perform a DNS check using ruby's built-in Resolv library

```ruby
class User < ActiveRecord::Base
  attr_accessible :domain
  validates :domain, :domain => {:verify_dns => true}

  # Also supports a custom message when failing DNS check
  # validates :domain, :domain => {:verify_dns => {:message => "DNS check failed"}}
end
```

DomainValidator can also check that the domain points to the same IP
as a given domain. This is useful if you want users to set up their
own CNAME for a given domain.

```ruby
class User < ActiveRecord::Base
  attr_accessible :domain
  validates :domain, :domain => {:verify_dns => true, :same_ip_as => "domains.myservice.com"}

  # Also supports different messages for missing or incorrect DNS records
  # validates :domain, :domain => {
  #   :verify_dns => {
  #     :same_ip_as => "domains.myservice.com",
  #     :missing_dns_record => "DNS record not found",
  #     :incorrect_dns_record => "Ensure domain is a CNAME for domains.myservice.com"
  #   }
  # }
end
```

The `:same_ip_as` option also supports taking a lambda in case you
need to read the value from a lazily initialized resource.

```ruby
class User < ActiveRecord::Base
  attr_accessible :domain

  validates :domain, :domain => {
    :verify_dns => {
      :same_ip_as => lambda { SomeLazy.config.domain }
    }
  }
end
```

## Examples

```ruby
user = User.new :domain => 'mydomain.com'
user.valid? # => true

user.domain = 'invalid*characters.com'
user.valid? # => false
```

## Translations

The default error messages can be overridden via translations:

    activerecord:
      errors:
        models:
          user:
            attributes:
              domain:
                invalid_domain: "Not a valid domain."
                missing_dns_record: "DNS record not found."
                invalid_dns_record: "DNS record is not setup correctly."

See
[Rails documentation](http://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-generate_message)
for a full list of possible translation scopes.

## Compatibility

DomainValidator is tested against:

MRI 1.9.3, 2.0, 2.1.1, 2.1.2
JRuby 1.9
Rubinus 2.1.1

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Add some specs (so I don't accidentally break your functionality in future versions)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request
