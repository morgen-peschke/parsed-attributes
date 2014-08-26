require_relative '../base'
require_relative '../../parsers/http/cookie'
module Parsed
  module HTTP
    module Cookie
      include Parsed::Base

      ##
      # Defines an attribute pair to handle HTTP cookie data
      # ---
      # Accepts default options, see Parsed::Base
      def http_cookie_attribute(name, options = {})
        __define_parsed_attributes_all_methods name, options do |raw_value|
          ::Parsers::HTTP::Cookie.parse raw_value
        end
      end
    end
  end
end
