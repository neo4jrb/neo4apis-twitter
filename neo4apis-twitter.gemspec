lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name     = "neo4apis-twitter"
  s.version  = '0.8.3'
  s.required_ruby_version = ">= 1.9.1"

  s.authors  = "Brian Underwood"
  s.email    = 'public@brian-underwood.codes'
  s.homepage = "https://github.com/neo4jrb/neo4apis-twitter/"
  s.summary = "An ruby gem to import twitter data to neo4j"
  s.license = 'MIT'
  s.description = <<-EOF
A ruby gem using neo4apis to make importing twitter data to neo4j easy
  EOF

  s.require_path = 'lib'
  s.files = Dir.glob("{bin,lib,config}/**/*") + %w(README.md Gemfile neo4apis-twitter.gemspec)

  s.add_dependency('neo4apis', '>= 0.8.1')
  s.add_dependency('twitter', '~> 5.12.0')

end
