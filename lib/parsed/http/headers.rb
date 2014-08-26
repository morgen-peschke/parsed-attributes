require_relative '../base'
require_relative '../../parsers/http/headers'
module Parsed
  module HTTP
    module Headers
      include Parsed::Base

      ##
      # Defines an attribute pair to handle HTTP header blocks
      # ---
      # Accepts default options, see Parsed::Base
      def http_headers_attribute(name, options = {})
        __define_parsed_attributes_all_methods name, options do |raw_value|
          ::Parsers::HTTP::Headers.parse raw_value
        end
      end
    end
  end
end
