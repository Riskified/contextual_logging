$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "contextual_logging/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "contextual_logging"
  s.version     = ContextualLogging::VERSION
  s.authors     = ["John P. Terry"]
  s.email       = ["jterry@opengov.com"]
  s.homepage    = "https://github.com/OpenGov/contextual_logging"
  s.summary     = "Allows for a hash of context to be included with log messages"
  s.description = "Allows for a hash of context to be included with log messages"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 4"
  s.add_dependency "logstash-event", "~> 1.2.02"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "pry"
  s.add_development_dependency "rspec-rails", "~> 2.14.1"
  s.add_development_dependency "test-unit", "~> 3.0"
  s.add_development_dependency "protected_attributes"
  s.add_development_dependency "jquery-rails"

end
