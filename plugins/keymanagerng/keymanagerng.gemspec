require_relative "lib/keymanagerng/version"
Gem::Specification.new do |spec|
  spec.name        = "keymanagerng"
  spec.version     = Keymanagerng::VERSION
  spec.authors     = ["Elektra UI team"]
  spec.summary     = "An Elektra plugin"
  spec.license     = "MIT"
  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end
