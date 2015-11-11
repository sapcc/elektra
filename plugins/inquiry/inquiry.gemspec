$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "inquiry/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "inquiry"
  s.version     = Inquiry::VERSION
  s.authors     = ["TODO: Write your name"]
  s.email       = ["TODO: Write your email address"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Inquiry."
  s.description = "TODO: Description of Inquiry."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_runtime_dependency "aasm"

  
end
