lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'neo4apis/twitter/version'

Gem::Specification.new do |s|
  s.name     = "neo4apis-twitter"
  s.version  = Neo4Apis::Twitter::VERSION
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

  s.add_dependency('neo4apis', "~> 0.0.1")

end
