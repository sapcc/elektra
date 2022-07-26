$:.push File.expand_path("lib", __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "object_storage_ng"
  spec.version     = "0.0.1"
  spec.authors     = ["Andreas Pfau"]
  spec.email       = ["andreas.pfau@sap.com"]
  spec.homepage    = ""
  spec.summary     = "Manage objects in swift"
  spec.license     = "MIT"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
end
