require_relative '../../test_helper'
require 'parsers/http/basic_auth'

class BasicAuthTest < MiniTest::Test

  def setup
    @famous_passwords = [
      ['Aladdin'     , 'open sesame'   , 'QWxhZGRpbjpvcGVuIHNlc2FtZQ==' ],
      ['Chuck Norris', ''              , 'Q2h1Y2sgTm9ycmlzOg=='         ],
      ['Wagstaff'    , 'Swordfish'     , 'V2Fnc3RhZmY6U3dvcmRmaXNo'     ],
      ['BClinton'    , 'Buddy'         , 'QkNsaW50b246QnVkZHk='         ],
      ['WOPR'        , 'Joshua'        , 'V09QUjpKb3NodWE='             ],
      ['911'         , 'IAcceptTheRisk', 'OTExOklBY2NlcHRUaGVSaXNr'     ],
      ['root'        , 'ZION0101'      , 'cm9vdDpaSU9OMDEwMQ=='         ],
      ['AirShield'   , '1234'          , 'QWlyU2hpZWxkOjEyMzQ='         ]
    ]
  end

  def test_basics
    @famous_passwords.each do |(username, password)|
      ba = Parsers::HTTP::BasicAuth.new username, password
      assert_equal username,                   ba.username
      assert_equal password,                   ba.password
      assert_equal "#{username}:#{password}",  ba.userpwd
    end
  end

  def test_to_s
    @famous_passwords.each do |(username, password, base64)|
      ba = Parsers::HTTP::BasicAuth.new username, password
      assert_equal base64, ba.to_s
      assert_equal base64, "#{ba}"
    end
  end

  def test_parse
    @famous_passwords.each do |(username, password, base64)|
      ba = Parsers::HTTP::BasicAuth.parse base64
      assert_equal username, ba.username
      assert_equal password, ba.password
    end
  end

  def test_round_trip
    @famous_passwords.each do |(username, password)|
      encoded = Parsers::HTTP::BasicAuth.new(username, password).to_s
      ba = Parsers::HTTP::BasicAuth.parse encoded
      assert_equal username, ba.username
      assert_equal password, ba.password
    end
  end

  def test_exceptions
    e = assert_raises(Parsers::HTTP::BasicAuth::ParserError, 'Malformed string, expecting ":"') do
      Parsers::HTTP::BasicAuth.parse ["no colon"].pack('m')
    end
    assert_equal 'Malformed string, expecting ":"', e.message

    e = assert_raises(Parsers::HTTP::BasicAuth::ParserError, 'Username cannot be blank') do
      Parsers::HTTP::BasicAuth.parse [":pass"].pack('m')
    end
    assert_equal 'Username cannot be blank', e.message
  end

end
