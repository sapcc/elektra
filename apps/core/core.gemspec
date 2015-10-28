$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "core/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "core"
  s.version     = Core::VERSION
  s.authors     = ["Andreas Pfau"]
  s.email       = ["andreas.pfau@sap.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Core."
  s.description = "TODO: Description of Core."

  s.files = Dir["{app,config,db,lib}/**/*", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "4.2.0"
end
