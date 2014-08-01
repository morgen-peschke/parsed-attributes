require 'minitest/autorun'
require_relative '../lib/parsed/json'

class JsonTest < MiniTest::Test

  class Wrapper
    extend Parsed::Json

    json_attribute :json
    json_attribute :raises_once,   raise:        true
    json_attribute :raises_always, raise_always: true
  end

  def setup
    super
    @test_obj = Wrapper.new

    @simple_raw    = %({"a":1})
    @simple_parsed = {'a' => 1}
  end
  
  

  def test_parsed
    @test_obj.raw_json        = @simple_raw
    
    assert_equal @simple_parsed, @test_obj.parsed_json, 'Parsed getter failed'

    @test_obj.raw_json          = 'This is clearly not JSON'
    @test_obj.raw_raises_once   = 'This is clearly not JSON'
    @test_obj.raw_raises_always = 'This is clearly not JSON'
    
    assert_equal nil, @test_obj.parsed_json, 'Failure should set to parsed nil'

    exception = assert_raises(JSON::ParserError, 'Should have raised the first time') {@test_obj.parsed_raises_once}
    assert exception.message.match(/unexpected token/), 'Unexpected parser error message'

    assert_nil @test_obj.parsed_raises_once, 'Parse should not attempt again until raw is reset when raise_always option is not set'

    exception = assert_raises(JSON::ParserError, 'Should have raised the first time') {@test_obj.parsed_raises_always}
    assert exception.message.match(/unexpected token/), 'Unexpected parser error message'

    exception = assert_raises(JSON::ParserError, 'Should have raised the second time') {@test_obj.parsed_raises_always}
    assert exception.message.match(/unexpected token/), 'Unexpected parser error message'
  end
    
end
