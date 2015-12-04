$:.push File.expand_path("../lib", __FILE__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "docs"
  s.version     = "0.0.1"
  s.authors     = ["Andreas Pfau"]
  s.email       = ["andreas.pfau@sap.com"]
  s.homepage    = "https://localhost/monsoon/monsoon-dashboard/tree/master/apps/docs"
  s.summary     = "Documentation Gem"
  s.description = "This gem includes documentation pages for Dashboard of Converged Cloud."

  s.files = Dir["{app,config,db,lib}/**/*", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

end
