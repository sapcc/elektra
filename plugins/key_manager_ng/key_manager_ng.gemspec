require_relative "lib/key_manager_ng/version"
Gem::Specification.new do |spec|
  spec.name        = "key_manager_ng"
  spec.version     = KeyManagerNg::VERSION
  spec.authors     = ["Elektra UI team"]
  spec.summary     = "An Elektra plugin"
  spec.license     = "MIT"
  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end
