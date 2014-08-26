require_relative '../../test_helper'
require 'parsed/http/cookie'

class HTTPCookieTest < MiniTest::Test
  class Wrapper
    extend Parsed::HTTP::Cookie
    http_cookie_attribute :cookie
    http_cookie_attribute :raises_never
    http_cookie_attribute :raises_once,   raise_once:   true
    http_cookie_attribute :raises_always, raise:        true
  end

  def setup
    super
    @test_obj = Wrapper.new
    @raw = 'first=carl'
    @broken = 'clearly not a cookie'
    @parsed = Parsers::HTTP::Cookie.parse @raw
  end

  def test_raw
    @test_obj.instance_variable_set '@parsed_cookie', Parsers::HTTP::Cookie.parse('first=bob')
    @test_obj.raw_cookie = @raw

    assert_equal @raw,  @test_obj.instance_variable_get('@raw_cookie'),         'Raw setter failed'
    assert_equal @raw,  @test_obj.raw_cookie,                                   'Raw getter failed'
    assert_equal false, @test_obj.instance_variable_defined?('@parsed_cookie'), 'Parsed not unset'
  end

  def test_parsed
    @test_obj.raw_cookie      = @raw
    @test_obj.raw_raises_once = @raw

    assert_equal @parsed,  @test_obj.parsed_cookie, "Parsed getter failed: #{@test_obj.parsed_cookie.inspect}"

    @test_obj.raw_raises_never  = @broken
    @test_obj.raw_raises_once   = @broken
    @test_obj.raw_raises_always = @broken

    assert_equal nil, @test_obj.parsed_raises_never, 'Failure should set parsed to nil'

    assert_raises(Parsers::HTTP::Cookie::ParserError, 'Should have raised the first time') {@test_obj.parsed_raises_once}
    assert_nil @test_obj.parsed_raises_once, 'Parse should not attempt again until raw is reset when raise_always option is not set'

    assert_raises(Parsers::HTTP::Cookie::ParserError, 'Should have raised the first time')  {@test_obj.parsed_raises_always}
    assert_raises(Parsers::HTTP::Cookie::ParserError, 'Should have raised the second time') {@test_obj.parsed_raises_always}
  end

end
