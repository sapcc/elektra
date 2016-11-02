$:.push File.expand_path("../lib", __FILE__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "automation"
  s.version     = "0.0.1"
  s.authors     = ["Arturo Reuschenbach Puncernau"]
  s.email       = ["a.reuschenbach.puncernau@sap.com"]
  s.homepage    = ""
  s.summary     = "Automation service"
  s.description = "Automation service"
  s.license     = "Apache 2"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency 'virtus'
end
