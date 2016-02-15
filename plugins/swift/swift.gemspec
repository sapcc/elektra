$:.push File.expand_path("../lib", __FILE__)



# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "swift"
  s.version     = Swift::VERSION
  s.authors     = [" Write your name"]
  s.email       = [" Write your email address"]
  s.homepage    = ""
  s.summary     = " Summary of Swift."
  s.description = " Description of Swift."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  
  
end
