module Parsed
  module Base
    
    def __define_parsed_attributes_raw_methods(name)
      attr_reader "raw_#{name}"
      
      define_method "raw_#{name}=" do |raw|
        self.instance_variable_set("@raw_#{name}", raw)
        if self.instance_variable_defined?("@parsed_#{name}")
          self.remove_instance_variable("@parsed_#{name}")
        end
      end
    end

    def __define_parsed_attributes_parsed_methods(name, options={}, &parse_block)
      parsed_varname = "@parsed_#{name}"

      define_method "parsed_#{name}" do
        if self.instance_variable_defined? parsed_varname
          return self.instance_variable_get parsed_varname
        end

        unless parse_block.nil?
          begin
            parsed = parse_block.call self.instance_variable_get("@raw_#{name}")
            self.instance_variable_set(parsed_varname, parsed)          
          rescue StandardError => e
            unless options[:raise_always] == true
              self.instance_variable_set(parsed_varname, nil)
            end
            raise e if options[:raise] == true || options[:raise_always] == true
          end
        end
        
        return self.instance_variable_get(parsed_varname)
      end
    end
    
    def __define_parsed_attributes_all_methods(name, options={}, &parse_block)
      __define_parsed_attributes_raw_methods    name
      __define_parsed_attributes_parsed_methods name, options, &parse_block
    end
  end
end
