Parsed Attributes
=================

This grew out of a need to give structure to the data in HTTP requests and
responses. Parsing it was easy enough, but I found myself duplicating a bunch of
code. This was how I fixed that problem.

TL;DR
-----

Raw data in, parsed data out.

Install
-------

### Global
```bash
gem install parsed-attributes
```

### Gemfile
```ruby
gem gem 'parsed-attributes'
```

Basic Usage
-----------

```ruby
require 'parsed-attributes'

class SomeExampleClass
  extend Parsed::SomeDataType

  some_data_type_attribute :name
end
```

This is the hand coded equivalent:

```ruby
class SomeExampleClass
  attr_reader :raw_name

  def raw_name=(data)
    @raw_name = data
    @parsed_name = nil
    @raw_name
  end

  def parsed_name
    return @parsed_name unless @parsed_name.nil?

    # parse the data

    @parsed_name
  end
end
```
