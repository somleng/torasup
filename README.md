# Torasup

Retuns metadata about a phone number such as operator info, area code and more.

[![Build Status](https://travis-ci.org/dwilkie/torasup.png)](https://travis-ci.org/dwilkie/torasup) [![Dependency Status](https://gemnasium.com/dwilkie/torasup.png)](https://gemnasium.com/dwilkie/torasup) [![Code Climate](https://codeclimate.com/github/dwilkie/torasup.png)](https://codeclimate.com/github/dwilkie/torasup)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'torasup'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install torasup
```

## Usage

### Returning info about a Phone Number

```
$ irb
```

```ruby
require 'torasup'

pn = Torasup::PhoneNumber.new("+855 (0) 62 451 2345")

pn.number
=> "85562451234"

pn.country_code
=> "855"

pn.country_id
=> "kh"

pn.area_code
=> "62"

pn.prefix
=> "45"

pn.local_number
=> "12345"

loc = pn.location
loc.area
=> "Kampong Thom"

op = pn.operator

op.id
=> "smart"

op.name
=> "Smart"
```

### Accessing Metadata by Operator

```ruby
Torasup::Operator.all["kh"]["metfone"]["mobile_prefixes"]
=> {"85538"=>{"subscriber_number_min"=>2000000, "subscriber_number_max"=>9999999, "subscriber_number_pattern"=>"[2-9]\\d{6}"}}
```

### Accessing Metadata by Prefix

```ruby
Torasup.prefixes["8552345"]
=> {"country_id"=>"kh", "id"=>"smart", "name"=>"Smart", "subscriber_number_min"=>0, "subscriber_number_max"=>99999, "subscriber_number_pattern"=>"\\d{5}", "type"=>"landline", "prefix"=>"45", "area_code"=>"23"}
```

## Configuration

### Overriding Data

Sometimes it maybe necessary to override the data that Torasup provides. For example you may want to provide custom attributes for different operators. In order to achieve this you can provide a custom [psdn](http://en.wikipedia.org/wiki/Public_switched_telephone_network) data file. Custom files also support interpolations using the `%{interpolation}` [I18n syntax](http://guides.rubyonrails.org/i18n.html#interpolation). See the format of sample custom [pstn data file](https://github.com/dwilkie/torasup/blob/master/spec/support/custom_pstn.yaml) for more info. e.g.

```yaml
# my_pstn_data.yaml
---
kh:
  area_codes:
    "45": "New Province"
  operators:
    hello:
      metadata:
        name: Hello
        my_custom_property: hello-foo
        my_custom_interpolated_property: "hello-%{interpolation}"
        my_custom_boolean_property: true
      prefixes:
      - '15'
      - '16'
      - '81'
      - '87'
      area_code_prefixes:
      - '45'
```

```ruby
Torasup.configure do |config|
  config.custom_pstn_data_file = "my_pstn_data.yaml"
end

pn = Torasup::PhoneNumber.new("+855 (0) 62 451 2345")
op = pn.operator

op.id
=> "hello"

op.name
=> "Hello"

op.my_custom_property
=> "hello-foo"

op.my_custom_interpolated_property(:interpolation => "bar")
=> "hello-bar"

op.my_custom_boolean_property
=> true
```

### Registering Operators

Sometimes you may only be interested in certain prefixes. For example let's say you want to match phone numbers from a certain operator from the database. You can register operators for this purpose. e.g.

```ruby
Torasup.configure do |config|
  config.register_operators("kh", "cootel")
end

Torasup::Operator.registered
=> {"kh"=>{"cootel"=>{"country_id"=>"kh", "id"=>"cootel", "name"=>"CooTel", "mobile_prefixes"=>{"85538"=>{"subscriber_number_min"=>2000000, "subscriber_number_max"=>9999999, "subscriber_number_pattern"=>"[2-9]\\d{6}"}}
}}}
```

### Default Operators

By default the following counties will take precedence: `["US", "GB", "AU", "IT", "RU", "NO"]`. To override use the following configuration setting:

```ruby
Torasup::PhoneNumber.new("+1 415-234 567").country_id
=> "us"

Torasup.configure do |config|
  config.default_countries = ["CA"]
end

Torasup::PhoneNumber.new("+1 415-234 567").country_id
=> "ca"
```

## Testing

Torasup exposes a few test helpers methods which you can use in your tests. See [the helper module](https://github.com/dwilkie/torasup/blob/master/lib/torasup/test/helpers.rb) for more info.

Here's an example using rspec:

```ruby
require 'spec_helper'

describe User do
  include Torasup::Test::Helpers

  ASSERTED_REGISTERED_OPERATORS = {"kh" => %w{smart beeline hello}}

  # override this method to return the full path of the yaml spec
  def yaml_file(filename)
    File.join(File.dirname(__FILE__), "/#{filename}")
  end

  # provide a custom spec file for example see:
  # see https://github.com/dwilkie/torasup/blob/master/spec/support/custom_pstn_spec.yaml
  def pstn_data(custom_spec = nil)
    super("custom_operators_spec.yaml")
  end

  def with_operators(&block)
    super(:only_registered => ASSERTED_REGISTERED_OPERATORS, &block)
  end

  describe "#operator" do
    it "should return the correct operator" do
      with_operators do |number_parts, assertions|
        new_user = build(:user, :phone_number => number_parts.join)
        new_user.operator.should == assertions["name"]
      end
    end
  end
end
```

In this example `with_operators` is used to yield a to block with a sample number (yielded as `number_parts`) and a hash of assertions (yielded as `assertions`) made about that number. The assertions are defined in `custom_operators_spec.yaml` which is in the same directory as this spec file.

Sample numbers and assertions are only yielded for the operators defined in `ASSERTED_REGISTERED_OPERATORS`

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

### Data

When contributing data please ensure that you create or edit an entry in the [pstn spec](https://github.com/dwilkie/torasup/tree/master/spec/torasup/spec/support_pstn_spec.rb). This ensures the integrity of the data.

Please also include a link to Wikipedia article which verifies your data. See the [current psdn spec](https://github.com/dwilkie/torasup/blob/master/spec/support/pstn_spec.yaml) for an example that links to [Wikipedia](http://en.wikipedia.org/wiki/Telecommunications_in_Cambodia#Mobile_networks).

If you obtained operator prefixes from another source please clearly add these prefixes to the appropriate Wikipedia article and reference it if necessary. This helps ensure the accuracy of the gem.
