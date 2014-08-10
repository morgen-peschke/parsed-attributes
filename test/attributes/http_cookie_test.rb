require 'minitest/autorun'
require_relative '../../lib/parsed/http/cookie'

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
  end

  def test_raw
    @test_obj.instance_variable_set '@parsed_cookie', Cookie.parse('first=bob')
    @test_obj.raw_cookie = 'first=carl'

    assert_equal 'first=carl', @test_obj.instance_variable_get('@raw_cookie'),         'Raw setter failed'
    assert_equal 'first=carl', @test_obj.raw_cookie,                                   'Raw getter failed'
    assert_equal false,        @test_obj.instance_variable_defined?('@parsed_cookie'), 'Parsed not unset'
  end

  def test_parsed
    @test_obj.raw_cookie = 'first=carl'
    @test_obj.raw_raises_once = 'first=carl'
    p @test_obj.parsed_raises_once
    assert @test_obj.parsed_cookie.is_a?(Cookie), "Parsed getter failed: #{@test_obj.parsed_cookie.inspect}"

    @test_obj.raw_raises_never  = 'clearly not JSON'
    @test_obj.raw_raises_once   = 'clearly not JSON'
    @test_obj.raw_raises_always = 'clearly not JSON'

    assert_equal nil, @test_obj.parsed_raises_never, 'Failure should set parsed to nil'

    assert_raises(Cookie::ParserError, 'Should have raised the first time') {@test_obj.parsed_raises_once}
    assert_nil @test_obj.parsed_raises_once, 'Parse should not attempt again until raw is reset when raise_always option is not set'

    assert_raises(Cookie::ParserError, 'Should have raised the first time')  {@test_obj.parsed_raises_always}
    assert_raises(Cookie::ParserError, 'Should have raised the second time') {@test_obj.parsed_raises_always}
  end

end
