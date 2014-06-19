Gem::Specification.new do |s|
  s.name        = 'cache_pipe'
  s.version     = '0.2'
  s.date        = Date.today.to_s
  s.summary     = "Transforming wrapper for Rails cache stores"
  s.description = "Provides a wrapper around a Rails cache store, allowing values to be transformed before storage and after retrieval."
  s.authors     = ["Tony Novak"]
  s.email       = 'engineering@amitree.com'
  s.files       = Dir.glob("{bin,lib}/**/*") + %w(LICENSE README.md)

  s.homepage    = 'https://github.com/amitree/cache_pipe'
  s.license     = 'MIT'

  s.required_ruby_version = '~> 2.0'

  s.add_development_dependency 'rspec', '3.0.0'
end
