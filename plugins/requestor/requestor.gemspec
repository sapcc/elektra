$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "requestor/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "requestor"
  s.version     = Requestor::VERSION
  s.authors     = ["TODO: Write your name"]
  s.email       = ["TODO: Write your email address"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Requestor."
  s.description = "TODO: Description of Requestor."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_runtime_dependency "aasm"

  
end
