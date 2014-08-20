class BasicAuth
  class ParserError < StandardError
  end

  attr_accessor :username, :password
  def initialize(user, pass)
    @username = user
    @password = pass
  end

  def userpwd
    "#{@username}:#{@password}"
  end

  def to_s
    [self.userpwd].pack('m').strip
  end

  def self.parse(raw_value)
    decoded = raw_value.unpack("m").first
    si = decoded.index ':'
    raise ParserError.new 'Malformed string, expecting ":"' if si.nil?

    username = decoded[0...si]
    password = decoded[si + 1..-1]

    raise ParserError.new 'Username cannot be blank' if username.empty?
    self.new username, password
  end

end
