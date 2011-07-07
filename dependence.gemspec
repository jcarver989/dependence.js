Gem::Specification.new do |spec|
  spec.name ="dependence"
  spec.version = "0.0.2"
  spec.summary = "An easy way to handle your client side javascript dependencies"
  spec.authors = ["Joshua Carver"]
  spec.email = "jcarver989@gmail.com"
  spec.executables = ["dependence"]
  spec.has_rdoc = false
  spec.require_paths = ["lib", "compiler"]
  spec.files = []
  spec.files += Dir.glob "bin/*"
  spec.files += Dir.glob "compiler/*"
  spec.files += Dir.glob "lib/**/*"
end
