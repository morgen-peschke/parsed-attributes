require_relative '../../test_helper'
require 'parsed/http/basic_auth'

class HTTPBasicAuthTest < MiniTest::Test
  class Wrapper
    extend Parsed::HTTP::BasicAuth
    http_basic_auth_attribute :basicauth
    http_basic_auth_attribute :raises_never
    http_basic_auth_attribute :raises_once,   raise_once:   true
    http_basic_auth_attribute :raises_always, raise:        true
  end

  def setup
    super
    @test_obj = Wrapper.new
    @raw    = 'Q2h1Y2sgTm9ycmlzOg=='
    @broken = ['missing colon'].pack('m')
    @parsed = Parsers::HTTP::BasicAuth.parse @raw
  end

  def test_raw
    @test_obj.instance_variable_set '@parsed_basicauth', Parsers::HTTP::BasicAuth.parse('QWxhZGRpbjpvcGVuIHNlc2FtZQ==')
    @test_obj.raw_basicauth = @raw

    assert_equal @raw,  @test_obj.instance_variable_get('@raw_basicauth'),         'Raw setter failed'
    assert_equal @raw,  @test_obj.raw_basicauth,                                   'Raw getter failed'
    assert_equal false, @test_obj.instance_variable_defined?('@parsed_basicauth'), 'Parsed not unset'
  end

  def test_parsed
    @test_obj.raw_basicauth   = @raw
    @test_obj.raw_raises_once = @raw

    assert_equal @parsed, @test_obj.parsed_basicauth, "Parsed getter failed: #{@test_obj.parsed_basicauth.inspect}"

    @test_obj.raw_raises_never  = @broken
    @test_obj.raw_raises_once   = @broken
    @test_obj.raw_raises_always = @broken

    assert_equal nil, @test_obj.parsed_raises_never, 'Failure should set parsed to nil'

    assert_raises(Parsers::HTTP::BasicAuth::ParserError, 'Should have raised the first time') {@test_obj.parsed_raises_once}
    assert_nil @test_obj.parsed_raises_once, 'Parse should not attempt again until raw is reset when raise_always option is not set'

    assert_raises(Parsers::HTTP::BasicAuth::ParserError, 'Should have raised the first time')  {@test_obj.parsed_raises_always}
    assert_raises(Parsers::HTTP::BasicAuth::ParserError, 'Should have raised the second time') {@test_obj.parsed_raises_always}
  end

end
