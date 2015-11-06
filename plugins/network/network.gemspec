$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "network/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "network"
  s.version     = Network::VERSION
  s.authors     = ["Andreas Pfau"]
  s.email       = ["andreas.pfau@sap.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Network."
  s.description = "TODO: Description of Network."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

end
