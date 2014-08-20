require 'minitest/autorun'
require_relative '../../lib/parsed/http/basicauth'

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
  end

  def test_raw
    @test_obj.instance_variable_set '@parsed_basicauth', BasicAuth.parse('QWxhZGRpbjpvcGVuIHNlc2FtZQ==')
    @test_obj.raw_basicauth = 'Q2h1Y2sgTm9ycmlzOg=='

    assert_equal 'Q2h1Y2sgTm9ycmlzOg==', @test_obj.instance_variable_get('@raw_basicauth'),         'Raw setter failed'
    assert_equal 'Q2h1Y2sgTm9ycmlzOg==', @test_obj.raw_basicauth,                                   'Raw getter failed'
    assert_equal false,                  @test_obj.instance_variable_defined?('@parsed_basicauth'), 'Parsed not unset'
  end

  def test_parsed
    @test_obj.raw_basicauth   = 'QWxhZGRpbjpvcGVuIHNlc2FtZQ=='
    @test_obj.raw_raises_once = 'QWxhZGRpbjpvcGVuIHNlc2FtZQ=='

    assert @test_obj.parsed_basicauth.is_a?(BasicAuth), "Parsed getter failed: #{@test_obj.parsed_basicauth.inspect}"

    @test_obj.raw_raises_never  = ['missing colon'].pack('m')
    @test_obj.raw_raises_once   = ['missing colon'].pack('m')
    @test_obj.raw_raises_always = ['missing colon'].pack('m')

    assert_equal nil, @test_obj.parsed_raises_never, 'Failure should set parsed to nil'

    assert_raises(BasicAuth::ParserError, 'Should have raised the first time') {@test_obj.parsed_raises_once}
    assert_nil @test_obj.parsed_raises_once, 'Parse should not attempt again until raw is reset when raise_always option is not set'

    assert_raises(BasicAuth::ParserError, 'Should have raised the first time')  {@test_obj.parsed_raises_always}
    assert_raises(BasicAuth::ParserError, 'Should have raised the second time') {@test_obj.parsed_raises_always}
  end

end
