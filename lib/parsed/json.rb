require_relative 'base'
require 'json'

module Parsed
  module Json
    include Parsed::Base

    ##
    # Defines an attribute pair to handle JSON encoded date
    # ---
    # Accepts default options, see Parsed::Base    
    def json_attribute(name, options = {})      
      __define_parsed_attributes_all_methods name, options do |raw_value|
        JSON.parse raw_value
      end
    end
  end
end
