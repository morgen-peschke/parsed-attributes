require 'minitest/autorun'
require 'date'
require_relative '../../../lib/parsers/http/headers'

class HeadersTest < MiniTest::Test

  def test_object
    header = Parsers::HTTP::Headers.new 'key1' => 'val1', :key2 => 'val2', 'key3' => 'val3'

    assert_equal 'val1', header[:key1]
    assert_equal 'val2', header[:key2]
    assert_equal 'val3', header[:key3]

    assert_equal 'val1', header['key1']
    assert_equal 'val2', header['key2']
    assert_equal 'val3', header['key3']

    assert_equal 'val1', header.key1
    assert_equal 'val2', header.key2
    assert_equal 'val3', header.key3

    header.key1 = 'val1.1'
    header.key2 = 'val2.1'
    header.key3 = 'val3.1'

    assert_equal 'val1.1', header.key1
    assert_equal 'val2.1', header.key2
    assert_equal 'val3.1', header.key3

    assert_equal true,   header.respond_to?('new_key=')
    assert_equal false,  header.respond_to?('new_key' )

    header.new_key = 'test'

    assert_equal true,   header.respond_to?('new_key' )
    assert_equal 'test', header.new_key
  end

  def test_parse
    raw = <<EOF
Date: Mon, 25 Aug 2014 23:51:12 GMT
Server: Apache/2.4.9 (Debian)
Last-Modified: Fri, 06 Jun 2014 04:32:50 GMT
ETag: "192-4fb235aaa3898"
Accept-Ranges: bytes
Content-Length: 402
Set-Cookie: UserID=JohnDoe; Max-Age=3600; Version=1
Authorization: Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==
Vary: Accept-Encoding
Content-Type: text/html
EOF
    keys     = %w(date server last-modified etag accept-ranges content-length set-cookie authorization vary content-type)
    date     = DateTime.httpdate 'Mon, 25 Aug 2014 23:51:12 GMT'
    modified = DateTime.httpdate 'Fri, 06 Jun 2014 04:32:50 GMT'
    parsed   = Parsers::HTTP::Headers.parse raw
    cookie   = Parsers::HTTP::Cookie.parse 'UserID=JohnDoe; Max-Age=3600; Version=1'
    auth     = Parsers::HTTP::BasicAuth.parse 'QWxhZGRpbjpvcGVuIHNlc2FtZQ=='

    assert_equal keys,       parsed.keys
    keys.each                             {|k| assert_equal true,  parsed.key?(k) }
    keys.map(&:upcase).each               {|k| assert_equal true,  parsed.key?(k) }
    %w(Nitwit Blubber Oddment Tweak).each {|k| assert_equal false, parsed.key?(k) }

    assert_equal "Apache/2.4.9 (Debian)", parsed['server']
    assert_equal "Apache/2.4.9 (Debian)", parsed[:server]
    assert_equal "Apache/2.4.9 (Debian)", parsed['Server']
    assert_equal "Apache/2.4.9 (Debian)", parsed['SERVER']
    assert_equal "Apache/2.4.9 (Debian)", parsed.server

    assert_equal date,                parsed['date']
    assert_equal modified,            parsed['last-modified']
    assert_equal "192-4fb235aaa3898", parsed['etag']
    assert_equal 'bytes',             parsed['accept-ranges']
    assert_equal 402,                 parsed['content-length']
    assert_equal 'Accept-Encoding',   parsed['vary']
    assert_equal 'text/html',         parsed['Content-Type']
    assert_equal cookie,              parsed['set-cookie']
    assert_equal auth,                parsed['authorization']
  end

end
