$:.push File.expand_path("lib", __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "email_service"
  spec.version     = "0.0.1"
  spec.authors     = ["Sirajudheen Mohamed Ali"]
  spec.email       = ["sirajudheen.mohamed.ali@sap.com"]
  spec.homepage    = ""
  spec.summary     = "eMailService AWS SES Proxy"
  spec.description = "eMailService UI elektra plugin for Cronus"
  spec.license     = "MIT"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

end
