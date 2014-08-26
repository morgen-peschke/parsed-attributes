require 'date'
require_relative 'cookie'
require_relative 'basic_auth'
module Parsers
  module HTTP
    class Headers
      class ParserError < StandardError
      end

      def initialize(data = {})
        @fields  = {}

        data.each do |k,v|
          self.add_field k
          @fields[k.to_s.downcase] = v
        end
      end

      def normalize_key(key)
        key.to_s.downcase
      end

      def [](key)
        @fields[normalize_key(key)]
      end

      def []=(key, val)
        key = normalize_key key
        self.add_field key unless self.respond_to? key

        @fields[key] = va
      end

      def key?(name)
        @fields.key? normalize_key(name)
      end

      def keys
        @fields.keys
      end

      def respond_to?(meth)
        return true if meth.to_s =~ /=$/
        super
      end

      def method_missing(meth, *args, &block)
        if meth.to_s =~ /=$/
          new_field = meth.to_s[0...-1]
          self.add_field new_field
          return self.send meth, *args, &block
        end
        super
      end

      def self.parse(raw_string, options = {})
        self.new Parser.new(raw_string, options).parse!
      end

      class Parser
        def initialize(raw_string, options = {})
          @raw = raw_string.encode 'utf-8', universal_newlines: true
          @best_effort = options[:best_effort]
        end

        def parse!
          lines = @raw.split "\n"

          headers = {}
          lines.each do |line|
            name, value = split_header line
            key = name.to_s.downcase

            begin
              # Fields which can/should have integer values
              if %w(retry-after content-length max-forwards age).include?(key) && value =~ /^-?\d+$/
                headers[name] = value.to_i

                # Fields which should have httpdate values
              elsif %w(accept-datetime date if-modified-since if-unmodified-since expires last-modified retry-after).include? key
                headers[name] = DateTime.httpdate value.strip

              else
                headers[name] = (
                  case key
                  when 'set-cookie' then Cookie.parse value
                  when 'authorization'
                    type, code = value.split
                    (type.downcase == 'basic' ? BasicAuth.parse(code) : value)
                  else value
                  end
                )
              end
            rescue StandardError => e
              raise e unless @best_effort
              headers[name] = value
            end
          end

          headers
        end

        def split_header(line)
          i = line.index ':'
          raise ParserError.new("Malformed header (#{line})") if i.nil?
          name  = line[0...i]
          value = line[i + 1..-1].strip
          value = value[1...-1] if value =~ /^".*"$/
          return [ name, value ]
        end
      end

      protected

      def add_field(name)
        name = name.to_s.downcase
        metaclass = class << self; self; end
        metaclass.send(:define_method, name)      { @fields[name] }
        metaclass.send(:define_method, "#{name}="){ |val| @fields[name] = val }
      end
    end
  end
end
