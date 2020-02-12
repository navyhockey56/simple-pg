lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require_relative 'lib/simple-pg/version'

Gem::Specification.new do |s|
  s.name        = "simple-pg"
  s.version     = SimplePG::VERSION
  s.authors     = ["Will Dengler"]
  s.email       = ["navyhockey56@gmail.com"]
  s.homepage    = "http://github.com/navyhockey56"
  s.summary     = "Manages postgres interractions"
  s.description = "Manages postgres interractions"

  s.files        = Dir.glob("lib/**/*") + %w(README.md CHANGELOG.md)
  s.require_path = 'lib'

  s.add_runtime_dependency 'bcrypt', '~> 3.0'
  s.add_runtime_dependency 'pg', '~> 1.0'
end
