Parsed Attributes
=================

This grew out of a need to give structure to the data in HTTP requests and
responses. Parsing it was easy enough (Ruby has great gems), but I found myself duplicating a bunch of
code to manage the raw and parsed data, exceptions and whatnot.

This was how I fixed that problem.

## Conventions

I'm going to use JSON as the data type for the examples, mostly
because it's short to write, and was the first supported data type.

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
  extend Parsed::Json

  json_attribute :data
end
```

This is a naive hand coded equivalent:

```ruby
require 'json'

class SomeExampleClass
  attr_reader :raw_data

  def raw_data=(data)
    @raw_data = data
    @parsed_data = nil
    @raw_data
  end

  def parsed_data
    return @parsed_data unless @parsed_data.nil?

    begin
      @parsed_data = JSON.parse @raw_data
    rescue StandardError
      @parsed_data = nil
    end
    @parsed_data
  end
end
```

Customizing Behavior
--------------------

The attribute defining methods accept some arguments that modify the
way exceptions and un-parseable data are handled.

### Default Behavior

```ruby
json_attribute :data
```

Exceptions during parsing are supressed.

If #raw_data returns un-parseable data, then #parsed_data returns nil.

### Raise once

```ruby
json_attribute :data, raises_once: true
```

Exceptions during parsing are propagated the first time after #raw_data= is called, and supressed thereafter.

If #raw_data returns un-parseable data, then #parsed_data returns nil (after the first time).

This setting is mostly for debugging. It allows catching and printing
parser exceptions once per data to avoid cluttering up the screen/logs.

This overrides the 'raise always' behavior.

### Raise always

```ruby
json_attribute :data, raises: true
```

Exceptions during parsing are always propagated.

Extending
---------

Most of the boilerplate code is abstracted away into a helper module,
creatively named 'base'.

Extending is really simple, take a look at the JSON parser wrapper for
a minimal example.

Roadmap
-------

- [x] JSON
- [ ] HTTP Headers
  - [ ] Generic
  - [ ] BasicAuth
  - [ ] Cookies
  - [ ] Multiple header blocks
- [ ] URI
