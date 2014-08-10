require 'minitest/autorun'
require_relative '../../lib/parsed/json'

class JsonTest < MiniTest::Test

  class Wrapper
    extend Parsed::JSON
    json_attribute :name
    json_attribute :raises_never
    json_attribute :raises_once,   raise_once:   true
    json_attribute :raises_always, raise:        true
  end

  def setup
    super
    @test_obj = Wrapper.new
  end

  def test_attribute_creation
    %w(name raises_never raises_once raises_always).each do |name|
      assert  @test_obj.respond_to?("raw_#{name}"),    "Missing raw_#{name}"
      assert  @test_obj.respond_to?("raw_#{name}="),   "Missing raw_#{name}="
      assert  @test_obj.respond_to?("parsed_#{name}"), "Missing parsed_#{name}"
      assert !@test_obj.respond_to?('pared_#{name}='), "Shouldn't define parsed_#{name}="
    end
  end

  def test_raw
    @test_obj.instance_variable_set('@parsed_name', {'first' => 'bob'})
    @test_obj.raw_name = '{"last":"carl"}'

    assert_equal '{"last":"carl"}', @test_obj.instance_variable_get('@raw_name'),         'Raw setter failed'
    assert_equal '{"last":"carl"}', @test_obj.raw_name,                                   'Raw getter failed'
    assert_equal false,             @test_obj.instance_variable_defined?('@parsed_name'), 'Parsed not unset'
  end

  def test_parsed
    @test_obj.raw_name = '{"last":"carl"}'

    assert_equal ({"last" => "carl"}), @test_obj.parsed_name, 'Parsed getter failed'

    @test_obj.raw_raises_never  = 'clearly not JSON'
    @test_obj.raw_raises_once   = 'clearly not JSON'
    @test_obj.raw_raises_always = 'clearly not JSON'

    assert_equal nil, @test_obj.parsed_raises_never, 'Failure should set parsed to nil'

    assert_raises(JSON::ParserError, 'Should have raised the first time') {@test_obj.parsed_raises_once}
    assert_nil @test_obj.parsed_raises_once, 'Parse should not attempt again until raw is reset when raise_always option is not set'

    assert_raises(JSON::ParserError, 'Should have raised the first time')  {@test_obj.parsed_raises_always}
    assert_raises(JSON::ParserError, 'Should have raised the second time') {@test_obj.parsed_raises_always}
  end
end
