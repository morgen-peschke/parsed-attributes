require_relative '../base'
require_relative '../../parsers/http/basic_auth'
module Parsed
  module HTTP
    module BasicAuth
      include Parsed::Base

      ##
      # Defines an attribute pair to handle de/encoding HTTP Basic auth strings
      # ---
      # Accepts default options, see Parsed:Base
      def http_basic_auth_attribute(name, options = {})
        __define_parsed_attributes_all_methods name, options do |raw_value|
          ::Parsers::HTTP::BasicAuth.parse raw_value
        end
      end
    end
  end
end
