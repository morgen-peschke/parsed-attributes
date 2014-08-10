module Parsed
  module Base

    ##
    # Helper to define the raw methods
    # ---
    # Expects:
    #  name (String):: Determines the method name.
    #                  For example: 'yaml' will create the methods
    #                   - #raw_yaml
    #                   - #raw_yaml=
    #
    #                  And assumes the instance variables:
    #                   - @raw_yaml
    #                   - @parsed_yaml
    def __define_parsed_attributes_raw_methods(name)
      attr_reader "raw_#{name}"

      define_method "raw_#{name}=" do |raw|
        self.instance_variable_set("@raw_#{name}", raw)

        if self.instance_variable_defined?("@parsed_#{name}")
          self.remove_instance_variable("@parsed_#{name}")
        end
      end
    end

    ##
    # Helper to define the parsed method
    # ---
    # This handles the behavior around exceptions, and setting/removing the
    # the instance variables.
    #
    # Expects:
    #  name (String):: Determines the method name.
    #                  For example: 'yaml' will create the method
    #                   - #parsed_yaml
    #
    #                  And assumes the instance variables:
    #                   - @raw_yaml
    #                   - @parsed_yaml
    #
    #  options (acts like Hash):: Modifies the exception handling behavior
    #                  raises_once (boolean):: Setting to true will raise on the first error.
    #
    #                                          This is mostly so that if you are catching and
    #                                          printing error messages they won't flood the
    #                                          terminal.
    #
    #                                          This overrides the raises option
    #
    #                  raises(boolean):: Setting to true will raise on every error.
    #
    # This method accepts a block, which is passed the raw value, and is expected to return
    # the parsed data.
    def __define_parsed_attributes_parsed_methods(name, options={}, &parse_block)
      parsed_varname = "@parsed_#{name}"
      raise_once   = options.delete :raise_once
      raise_always = options.delete :raise

      define_method "parsed_#{name}" do
        if self.instance_variable_defined? parsed_varname
          return self.instance_variable_get parsed_varname
        end

        unless parse_block.nil?
          begin
            parsed = parse_block.call self.instance_variable_get("@raw_#{name}")
            self.instance_variable_set(parsed_varname, parsed)
          rescue StandardError => e
            self.instance_variable_set(parsed_varname, nil) if raise_once == true
            raise e if raise_always == true || raise_once == true
          end
        end

        return self.instance_variable_get(parsed_varname)
      end
    end

    ##
    # Shortcut method for if the default behavior is desired.
    # ---
    # Refer to the documentation for the other methods
    def __define_parsed_attributes_all_methods(name, options={}, &parse_block)
      __define_parsed_attributes_raw_methods    name
      __define_parsed_attributes_parsed_methods name, options, &parse_block
    end
  end
end
