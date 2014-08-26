require          'minitest/autorun'
require          'timecop'
require_relative '../../../lib/parsers/http/cookie'

class CookieTest < MiniTest::Test

  def test_parse_cookie
    cookie = Parsers::HTTP::Cookie.parse 'name=value; Expires=Fri, 01 Aug 2014 12:10:14 GMT; max-age=-1; domain=test.example.com; path=/to_h; secure; httpOnly'
    assert_equal 'name',                          cookie.name
    assert_equal 'value',                         cookie.value
    assert_equal nil,                             cookie.expires
    assert_equal  Time.at(0),                     cookie.max_age
    assert_equal 'test.example.com',              cookie.domain
    assert_equal '/to_h',                         cookie.path
    assert_equal  true,                           cookie.secure
    assert_equal  true,                           cookie.http_only

    cookie = Parsers::HTTP::Cookie.parse 'name=value; Expires=Fri, 01 Aug 2014 12:10:14 GMT; domain=test.example.com; secure; httpOnly'
    assert_equal 'name',                          cookie.name
    assert_equal 'value',                         cookie.value
    assert_equal 'Fri, 01 Aug 2014 12:10:14 GMT', cookie.expires
    assert_equal  nil,                            cookie.max_age
    assert_equal 'test.example.com',              cookie.domain
    assert_equal  nil,                            cookie.path
    assert_equal  true,                           cookie.secure
    assert_equal  true,                           cookie.http_only

    cookie = Parsers::HTTP::Cookie.parse 'name=value; domain=test.example.com; httpOnly'
    assert_equal 'name',                          cookie.name
    assert_equal 'value',                         cookie.value
    assert_equal  nil,                            cookie.expires
    assert_equal  nil,                            cookie.max_age
    assert_equal 'test.example.com',              cookie.domain
    assert_equal  nil,                            cookie.path
    assert_equal  nil,                            cookie.secure
    assert_equal  true,                           cookie.http_only
  end

  def test_parse_cookie_exceptions
    e = assert_raises(Parsers::HTTP::Cookie::ParserError) { Parsers::HTTP::Cookie.parse "name=value; expires=" }
    assert_equal "Expires cannot have a blank value", e.message

    e = assert_raises(Parsers::HTTP::Cookie::ParserError) { Parsers::HTTP::Cookie.parse "name=value; max-age=" }
    assert_equal "Max-Age cannot have a blank value", e.message

    e = assert_raises(Parsers::HTTP::Cookie::ParserError) { Parsers::HTTP::Cookie.parse "name=value; max-age=blech" }
    assert_equal "Expected integer for Max-Age instead of blech", e.message

    e = assert_raises(Parsers::HTTP::Cookie::ParserError) { Parsers::HTTP::Cookie.parse "name=value; max-age=1234e5" }
    assert_equal "Expected integer for Max-Age instead of 1234e5", e.message

    e = assert_raises(Parsers::HTTP::Cookie::ParserError) { Parsers::HTTP::Cookie.parse "name=value; Domain=" }
    assert_equal "Domain cannot have a blank value", e.message
  end

  def test_cookie_to_string
    cookie   = Parsers::HTTP::Cookie.parse 'name=value; Expires=Fri, 01 Aug 2014 12:10:14 GMT; max-age=-1; domain=test.example.com; path=/to_h; secure; httpOnly'
    expected = 'name=value; Max-Age=0; Domain=test.example.com; Path=/to_h; Secure; HttpOnly'
    assert_equal expected, cookie.to_s

    cookie   = Parsers::HTTP::Cookie.parse 'name=value; MAX-AGE=-1; domain = test.example.com; path=/to_h; secure; httpOnly'
    expected = 'name=value; Max-Age=0; Domain=test.example.com; Path=/to_h; Secure; HttpOnly'
    assert_equal expected, cookie.to_s

    cookie = Parsers::HTTP::Cookie.parse 'name=value; max-age=120'
    assert_equal 'name=value; Max-Age=120', cookie.to_s

    time = Time.now
    Timecop.freeze(time) do
      cookie = Parsers::HTTP::Cookie.parse 'name=value; max-age=120', time: time
      assert_equal 'name=value; Max-Age=120', cookie.to_s
      Timecop.travel(time + 49) {assert_equal 'name=value; Max-Age=70', cookie.to_s}
    end
  end

  def test_cookie_to_hash
    cookie = Parsers::HTTP::Cookie.parse 'name=value; Expires=Fri, 01 Aug 2014 12:10:14 GMT; max-age=-1; domain=test.example.com; path=/to_h; secure; httpOnly'
    expected = {
      name:     'name',
      value:    'value',
      max_age:   Time.at(0),
      domain:   'test.example.com',
      path:     '/to_h',
      secure:    true,
      http_only: true
    }
    assert_equal expected, cookie.to_h

    cookie = Parsers::HTTP::Cookie.parse 'name=value; max-age=-1; domain=test.example.com; path=/to_h; httpOnly'
    expected = {
      name:     'name',
      value:    'value',
      max_age:   Time.at(0),
      domain:   'test.example.com',
      path:     '/to_h',
      http_only: true
    }
    assert_equal expected, cookie.to_h

    cookie = Parsers::HTTP::Cookie.parse 'name=value; domain=test.example.com; path=/to_h'
    expected = {
      name:   'name',
      value:  'value',
      domain: 'test.example.com',
      path:   '/to_h',
    }
    assert_equal expected, cookie.to_h
  end

  def test_parser_to_hash
    parser = Parsers::HTTP::Cookie::Parser.new
    parser.parse! 'name=value; Expires=Fri, 01 Aug 2014 12:10:14 GMT; max-age=-1; domain=test.example.com; path=/to_h; secure; httpOnly'
    expected = {
      name:     'name',
      value:    'value',
      max_age:   Time.at(0),
      domain:   'test.example.com',
      path:     '/to_h',
      secure:    true,
      http_only: true
    }
    assert_equal expected, parser.to_h

    parser.parse! 'name=value; max-age=-1; domain=test.example.com; path=/to_h; httpOnly'
    expected = {
      name:     'name',
      value:    'value',
      max_age:   Time.at(0),
      domain:   'test.example.com',
      path:     '/to_h',
      http_only: true
    }
    assert_equal expected, parser.to_h

    parser.parse! 'name=value; domain=test.example.com; path=/to_h'
    expected = {
      name:   'name',
      value:  'value',
      domain: 'test.example.com',
      path:   '/to_h',
    }
    assert_equal expected, parser.to_h
  end

  def test_parsing_name_and_value
    parser = Parsers::HTTP::Cookie::Parser.new

    e = assert_raises(Parsers::HTTP::Cookie::ParserError) { parser.parse! }
    assert_equal "nil is unparseable", e.message

    ["", ';', '=test'].each do |cookie|
      e = assert_raises(Parsers::HTTP::Cookie::ParserError) { parser.parse! cookie}
      assert_equal "Name cannot be blank", e.message, "'#{cookie}' failed"
    end

    ['string', '; stuff'].each do |cookie|
      e = assert_raises(Parsers::HTTP::Cookie::ParserError) { parser.parse! cookie }
      assert_equal "Name/value pair must include '='", e.message, "'#{cookie}' failed"
    end

    parser.parse! "some_key=some_val"
    assert_equal  "some_key", parser.name
    assert_equal  "some_val", parser.value
  end

  def test_parsing_expiration
    parser = Parsers::HTTP::Cookie::Parser.new

    parser.parse! "name=value; Expires=Wed, 09 Jun 2021 10:18:14 GMT"
    assert_equal  "name",  parser.name
    assert_equal  "value", parser.value
    assert_equal  "Wed, 09 Jun 2021 10:18:14 GMT", parser.expires

    e = assert_raises(Parsers::HTTP::Cookie::ParserError) { parser.parse! "name=value; expires=" }
    assert_equal "Expires cannot have a blank value", e.message
  end

  def test_parsing_max_age
    parser = Parsers::HTTP::Cookie::Parser.new

    e = assert_raises(Parsers::HTTP::Cookie::ParserError) { parser.parse! "name=value; max-age=" }
    assert_equal "Max-Age cannot have a blank value", e.message

    e = assert_raises(Parsers::HTTP::Cookie::ParserError) { parser.parse! "name=value; max-age=blech" }
    assert_equal "Expected integer for Max-Age instead of blech", e.message

    e = assert_raises(Parsers::HTTP::Cookie::ParserError) { parser.parse! "name=value; max-age=1234e5" }
    assert_equal "Expected integer for Max-Age instead of 1234e5", e.message

    assert_equal 1234,       parser.parse!("name=value; max-age=1234").max_age
    assert_equal Time.at(0), parser.parse!("name=value; max-age=0").max_age
    assert_equal Time.at(0), parser.parse!("name=value; max-age=-1234").max_age

    time = Time.now
    parser = Parsers::HTTP::Cookie::Parser.new(time: time)

    assert_equal time + 1234, parser.parse!("name=value; max-age=1234").max_age
    assert_equal Time.at(0),  parser.parse!("name=value; max-age=0").max_age
    assert_equal Time.at(0),  parser.parse!("name=value; max-age=-1234").max_age
  end

  def test_domain
    parser = Parsers::HTTP::Cookie::Parser.new

    e = assert_raises(Parsers::HTTP::Cookie::ParserError) { parser.parse! "name=value; Domain=" }
    assert_equal "Domain cannot have a blank value", e.message

    assert_equal 'example.com', parser.parse!('name=value; domain=example.com').domain
    assert_equal 'example.com', parser.parse!('name=value; domain=.example.com').domain
  end

  def test_path
    parser = Parsers::HTTP::Cookie::Parser.new

    assert_equal '', parser.parse!('name=value; path=').path
    assert_equal '', parser.parse!('name=value; path=bad_path').path
    assert_equal '/good_path', parser.parse!('name=value; path=/good_path').path

    parser = Parsers::HTTP::Cookie::Parser.new(default_path: '/default_path')

    assert_equal '/default_path', parser.parse!('name=value; path=').path
    assert_equal '/default_path', parser.parse!('name=value; path=bad_path').path
    assert_equal '/good_path',    parser.parse!('name=value; path=/good_path').path
  end

  def test_secure
    parser = Parsers::HTTP::Cookie::Parser.new
    assert_equal nil,   parser.parse!('name=value').secure
    assert_equal false, parser.instance_variable_defined?('@secure')
    assert_equal true,  parser.parse!('name=value; secure').secure
  end

  def test_http_only
    parser = Parsers::HTTP::Cookie::Parser.new
    assert_equal nil,   parser.parse!('name=value').http_only
    assert_equal false, parser.instance_variable_defined?('@http_only')
    assert_equal true,  parser.parse!('name=value; httponly').http_only
    assert_equal true,  parser.parse!('name=value; HttpOnly').http_only
  end
end
