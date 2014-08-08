require 'minitest/autorun'
require_relative '../lib/parsed/base'

# A parser that doesn't parse for testing
module Parsed
  module TestParser
    include Parsed::Base
    def stupid_attribute(name)
      __define_parsed_attributes_all_methods name do |raw_value|
        "stupid #{raw_value}"
      end        
    end

    def broken_attribute(name, options = {})
      __define_parsed_attributes_all_methods name, options do |raw_value|
        1/0
      end
    end     
  end
end

class BaseTest < MiniTest::Test

  class Wrapper
    extend Parsed::TestParser
    stupid_attribute :name
    broken_attribute :raises_never
    broken_attribute :raises_once,   raise_once:   true
    broken_attribute :raises_always, raise:        true
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
    @test_obj.instance_variable_set('@parsed_name', 'cat')
    @test_obj.raw_name = 'cat'

    assert_equal 'cat', @test_obj.instance_variable_get('@raw_name'),         'Raw setter failed'
    assert_equal 'cat', @test_obj.raw_name,                                   'Raw getter failed'
    assert_equal false,  @test_obj.instance_variable_defined?('@parsed_name'), 'Parsed not unset'
  end

  def test_parsed
    @test_obj.raw_name = 'cat'

    assert_equal 'stupid cat', @test_obj.parsed_name, 'Parsed getter failed'

    @test_obj.raw_raises_never  = 'irrelevant'
    @test_obj.raw_raises_once   = 'irrelevant'
    @test_obj.raw_raises_always = 'irrelevant'
    
    assert_equal nil, @test_obj.parsed_raises_never, 'Failure should set parsed to nil'

    assert_raises(ZeroDivisionError, 'Should have raised the first time') {@test_obj.parsed_raises_once}
    assert_nil @test_obj.parsed_raises_once, 'Parse should not attempt again until raw is reset when raise_always option is not set'
    
    assert_raises(ZeroDivisionError, 'Should have raised the first time')  {@test_obj.parsed_raises_always}
    assert_raises(ZeroDivisionError, 'Should have raised the second time') {@test_obj.parsed_raises_always}
  end
end
