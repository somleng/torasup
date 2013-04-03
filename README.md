# Torasup

Retuns metadata about a phone number such as operator info, area code and more.

## Installation

Add this line to your application's Gemfile:

    gem 'torasup'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install torasup

## Usage

### Examples

    $ irb

    > require 'torasup'
    > pn = Torasup::PhoneNumber.new("+855 (0) 62 451 234")

    > pn.number
    => "85562451234"

    > pn.country_code
    => "855"

    > pn.country_id
    => "kh"

    > pn.area_code
    => "62"

    > pn.prefix
    => "45"

    > pn.local_number
    => "1234"

    > loc = pn.location
    > loc.area
    => "Kampong Thom"

    > op = pn.operator

    > op.id
    => "smart"

    > op.name
    => "Smart"

## Configuration

### Overriding Data

Sometimes it maybe necessary to override the data that Torasup provides. For example you may want to provide custom attributes for different operators. In order to achieve this you can provide a custom [psdn](http://en.wikipedia.org/wiki/Public_switched_telephone_network) data file. See the format of the [pstn data files](https://github.com/dwilkie/torasup/tree/master/lib/torasup/data) for more info. e.g.

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
          prefixes:
          - '15'
          - '16'
          - '81'
          - '87'
          area_code_prefixes:
          - '45'

    > Torasup.configure do |config|
    >   custom_pstn_data_file = "my_pstn_data.yaml"
    > end

    > pn = Torasup::PhoneNumber.new("+855 (0) 62 451 234")
    > op = pn.operator

    > op.id
    => "hello"

    > op.name
    => "Hello"

    > op.my_custom_property
    => "hello-foo"

### Registering Operators

Sometimes you may only be interested in certain prefixes. For example let's say you want to match phone numbers from a certain operator from the database. You can register operators for this purpose. e.g.

    > Torasup.configure do |config|
    >   register_operators("kh", "metfone")
    > end

    > Torasup::Operator.registered_prefixes
    =>  ["85597", "85588"]

### Default Operators

By default the following counties will take precedence: `["US", "GB", "AU", "IT", "RU", "NO"]`. This means that `Torasup::PhoneNumber.new(+1 415-234 567).country_id` will return `"us"` and not `ca`. To override use the following configuration setting.

    > Torasup.configure do |config|
    >   config.default_countries = ["CA"]
    > end

Now `Torasup::PhoneNumber.new(+1 415-234 567).country_id` will return `"ca"`

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

### Data

When contributing data please ensure that you create or edit the appropriate [spec](https://github.com/dwilkie/torasup/tree/master/spec/torasup/data). This ensures the integrity of the data..

Please also include a link to Wikipedia article which verifies your data. See the [Cambodian spec](https://github.com/dwilkie/torasup/tree/master/spec/torasup/data/kh.yaml) for an example that links to [Wikipedia](http://en.wikipedia.org/wiki/Telecommunications_in_Cambodia#Mobile_networks).

If you obtained operator prefixes from another source please clearly add these prefixes to the appropriate Wikipedia article and reference it if necessary. This helps ensure the accuracy of the gem.
