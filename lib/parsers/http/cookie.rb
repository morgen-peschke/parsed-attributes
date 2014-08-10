class Cookie
  class ParserError < StandardError
  end

  attr_accessor :name, :value, :expires, :max_age, :path, :domain, :secure, :http_only
  def initialize(data = {})
    @name      = data[:name]      if data.key? :name
    @value     = data[:value]     if data.key? :value
    @expires   = data[:expires]   if data.key? :expires
    @max_age   = data[:max_age]   if data.key? :max_age
    @path      = data[:path]      if data.key? :path
    @domain    = data[:domain]    if data.key? :domain
    @secure    = data[:secure]    if data.key? :secure
    @http_only = data[:http_only] if data.key? :http_only
  end

  def age_left
    return @max_age if @max_age.is_a? Fixnum
    return (@max_age - Time.now).to_i
  end

  def to_s
    cookie = ["#{@name}=#{@value}"]
    cookie << "Expires=#{@expires}" if defined? @expires
    cookie << "Max-Age=#{@max_age == Time.at(0) ? 0 : self.age_left }" if defined? @max_age
    cookie << "Domain=#{@domain}"   if defined? @domain
    cookie << "Path=#{@path}"       if defined? @path
    cookie << "Secure"              if defined? @secure
    cookie << "HttpOnly"            if defined? @http_only
    return cookie.join('; ')
  end

  def to_h
    h = { name: @name, value: @value }
    h[:expires]   = @expires   if defined? @expires
    h[:max_age]   = @max_age   if defined? @max_age
    h[:domain]    = @domain    if defined? @domain
    h[:path]      = @path      if defined? @path
    h[:secure]    = @secure    if defined? @secure
    h[:http_only] = @http_only if defined? @http_only
    return h
  end

  def self.parse(raw_value, options = {})
    self.new Parser.new(options).parse!(raw_value).to_h
  end

  class Parser
    attr_reader :name, :value, :expires, :max_age, :domain, :path, :secure, :http_only

    def initialize(options = {})
      @time         = options[:time]
      @default_path = options[:default_path] || ''
    end

    def to_h
      h = { name: @name, value: @value }
      h[:expires]   = @expires   if defined? @expires
      h[:max_age]   = @max_age   if defined? @max_age
      h[:domain]    = @domain    if defined? @domain
      h[:path]      = @path      if defined? @path
      h[:secure]    = @secure    if defined? @secure
      h[:http_only] = @http_only if defined? @http_only
      return h
    end

    def clear!
      %w(@name @value @expires @max_age @domain @path @secure @http_only).each do |var|
        if self.instance_variable_defined? var
          self.remove_instance_variable var
        end
      end
    end

    def parse!(raw_value = nil)
      raise ParserError.new "nil is unparseable" if raw_value.nil?
      self.clear!

      chunks = raw_value.to_s.split ';'
      chunks.map! do |c|
        si = c.index '='
        si.nil? ? [c.strip] : [ c[0...si].strip, c[si + 1..-1].strip ]
      end
      self.name_and_value! chunks.shift
      chunks.each {|c| self.attribute! c }
      return self
    end

    def name_and_value!(chunk)
      raise ParserError.new "Name cannot be blank"             if chunk.nil? or chunk.empty?
      raise ParserError.new "Name/value pair must include '='" if chunk.size == 1
      @name  = chunk[0]
      @value = chunk[1]

      raise ParserError.new "Name cannot be blank" if @name.empty?
    end

    def attribute!(chunk)
      key = chunk[0].downcase

      case key
      when 'expires'  then self.expires! chunk[1]
      when 'max-age'  then self.max_age! chunk[1]
      when 'domain'   then self.domain!  chunk[1]
      when 'path'     then self.path!    chunk[1]
      when 'secure'   then @secure    = true
      when 'httponly' then @http_only = true
      end
    end

    def expires!(val)
      raise ParserError.new 'Expires cannot have a blank value' if val.empty?
      @expires = val
    end

    def max_age!(val)
      raise ParserError.new 'Max-Age cannot have a blank value' if val.empty?

      unless val =~ /^-?\d+$/
        raise ParserError.new "Expected integer for Max-Age instead of #{val}"
      end

      val = val.to_i
      if val <= 0
        @max_age = Time.at(0)
      else
        @max_age = (@time.nil? ? val : @time + val)
      end
    end

    def domain!(val)
      raise ParserError.new 'Domain cannot have a blank value' if val.empty?
      @domain = (val[0] == '.' ? val[1..-1] : val).downcase
    end

    def path!(val)
      if val.empty? || val[0] != '/'
        @path = @default_path
      else
        @path = val
      end
    end

  end
end
