Gem::Specification.new do |spec|
  spec.name ="dependence"
  spec.version = "0.0.97"
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
  spec.add_dependency("rgl")
  spec.add_dependency("rb-inotify")
  spec.add_dependency("coffee-script")
  spec.add_dependency("therubyracer")

  spec.add_development_dependency('rspec')
end
