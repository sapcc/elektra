$:.push File.expand_path("../lib", __FILE__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = "block_storage"
  s.version = "0.0.1"
  s.authors = [" Write your name"]
  s.email = [" Write your email address"]
  s.homepage = ""
  s.summary = " Summary of BlockStorage."
  s.description = " Description of BlockStorage."
  s.license = "MIT"

  s.files =
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
end
