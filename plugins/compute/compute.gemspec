$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "compute/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "compute"
  s.version     = Compute::VERSION
  s.authors     = ["Andreas Pfau"]
  s.email       = ["andreas.pfau@sap.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Compute."
  s.description = "TODO: Description of Compute."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.2.0"
  s.add_dependency "core"
end
