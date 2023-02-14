$:.push File.expand_path("../lib", __FILE__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = "resource_management"
  s.version = "0.0.1"
  s.authors = ["Stefan Majewsky", "Hans-Georg Winkler"]
  s.email = %w[stefan.majewsky@sap.com hans-georg.winkler@sap.com]
  s.homepage = ""
  s.summary = "Manage quotas and resource usage in your cloud/domain/project."
  s.description =
    "Manage quotas and resource usage in your cloud/domain/project."
  s.license = "MIT"

  s.files =
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
end
