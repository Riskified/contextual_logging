$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "contextual_logging/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "contextual_logging"
  s.version     = ContextualLogging::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of ContextualLogging."
  s.description = "TODO: Description of ContextualLogging."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 3.2.19"

  s.add_development_dependency "sqlite3"
end
