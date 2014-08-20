Gem::Specification.new do |s|
  s.name        = 'parsed-attributes'
  s.version     = '0.1.2'
  s.date        = '2014-07-31'
  s.summary     = 'Generates paired attributes that parse their contents.'
  s.description = <<-EOF
                  Helps with parsing data by creating paired
                  attributes, a raw attribute, and a linked read-only
                  parsed attribute. The parsed attribute auto-updates
                  when the raw counterpart is updated.
EOF
  s.authors     = ['Morgen Peschke']
  s.email       = 'morgen.peschke@gmail.com'
  s.files       = Dir['lib/parsed/*.rb',
                      'lib/parsed/http/*.rb',
                      'lib/parsers/http/*.rb'
  ]
  s.homepage    = 'https://github.com/morgen-peschke/parsed-attributes'
  s.license     =  'MIT'
end
