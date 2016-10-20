$:.push File.expand_path("../lib", __FILE__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "cost_control"
  s.version     = "0.0.1"
  s.authors     = ["Arno Uhlig", "Stefan Majewsky"]
  s.email       = ["arno.uhlig@sap.com", "stefan.majewsky@sap.com"]
  s.homepage    = ""
  s.summary     = "Summary of CostControl."
  s.description = "Description of CostControl."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "fog-openstack-sap-billing" , "~> 0.0.9"

end
