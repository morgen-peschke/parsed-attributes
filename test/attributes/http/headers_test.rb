require 'minitest/autorun'
require_relative '../../../lib/parsed/http/headers'

class HTTPHeadersTest < MiniTest::Test
  class Wrapper
    extend Parsed::HTTP::Headers
    http_headers_attribute :headers
    http_headers_attribute :raises_never
    http_headers_attribute :raises_once,   raise_once:   true
    http_headers_attribute :best_effort,   raise_once:   true, best_effort: true
    http_headers_attribute :raises_always, raise:        true
  end

  def setup
    super
    @test_obj = Wrapper.new
    @raw = 'Server: Fake server'
    @broken = 'Date: not a date'
    @best_effort = Parsers::HTTP::Headers.parse @broken, best_effort: true
    @parsed = Parsers::HTTP::Headers.parse @raw
  end

  def test_raw
    @test_obj.instance_variable_set '@parsed_headers', Parsers::HTTP::Headers.parse('Server: none')
    @test_obj.raw_headers = @raw

    assert_equal @raw,  @test_obj.instance_variable_get('@raw_headers'),         'Raw setter failed'
    assert_equal @raw,  @test_obj.raw_headers,                                   'Raw getter failed'
    assert_equal false, @test_obj.instance_variable_defined?('@parsed_headers'), 'Parsed not unset'
  end

  def test_parsed
    @test_obj.raw_headers = @raw
    @test_obj.raw_raises_once = @raw

    assert_equal @parsed,  @test_obj.parsed_headers, "Parsed getter failed: #{@test_obj.parsed_headers.inspect}"

    @test_obj.raw_raises_never  = @broken
    @test_obj.raw_raises_once   = @broken
    @test_obj.raw_raises_always = @broken
    @test_obj.raw_best_effort   = @broken

    assert_equal nil, @test_obj.parsed_raises_never, 'Failure should set parsed to nil'

    assert_raises(Parsers::HTTP::Headers::ParserError, 'Should have raised the first time') do
      @test_obj.parsed_raises_once
    end
    assert_nil @test_obj.parsed_raises_once, 'Parse should not attempt again until raw is reset when raise_always option is not set'

    assert_raises(Parsers::HTTP::Headers::ParserError, 'Should have raised the first time')  do
      @test_obj.parsed_raises_always
    end
    assert_raises(Parsers::HTTP::Headers::ParserError, 'Should have raised the second time') do
      @test_obj.parsed_raises_always
    end

    assert_equal @best_effort, @test_obj.parsed_best_effort, 'Should have tried harder'
  end

end
