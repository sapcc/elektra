$:.push File.expand_path("../lib", __FILE__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = "inquiry"
  s.version = "0.0.1"
  s.authors = ["Write your name"]
  s.email = ["Write your email address"]
  s.homepage = ""
  s.summary = "Summary of Inquiry."
  s.description = "Description of Inquiry."
  s.license = "MIT"

  s.files =
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_runtime_dependency "aasm"
  s.add_runtime_dependency "kaminari"
  s.add_runtime_dependency "bootstrap-kaminari-views"
  s.metadata = { "mount_path" => "request" }
end
