$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "resource_management/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "resource_management"
  s.version     = ResourceManagement::VERSION
  s.authors     = ["TODO: Write your name"]
  s.email       = ["TODO: Write your email address"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of ResourceManagement."
  s.description = "TODO: Description of ResourceManagement."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  
  
end
