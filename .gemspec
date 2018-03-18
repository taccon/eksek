require File.join(__dir__, 'lib/eksek')

Gem::Specification.new do |s|
  s.name          = "eksek"
  s.version       = '0.1.0'
  s.authors       = ["Johnny Lee"]
  s.email         = ["jleeothon@icloud.com"]
  s.homepage      = "https://github.com/jleeothon/eksek"
  s.summary       = 'Execute shell commands'
  s.description   = 'Execute shell commands and specify what values to be returned e.g. stdout, stderr, exit code'
  s.license       = 'MIT'

  s.files         = Dir['lib/**/*.rb', 'LICENSE', 'README.md']
  s.test_files    = []
  s.require_paths = ["lib"]

  s.add_development_dependency "rake",    "~> 11"
  s.add_development_dependency "rspec",   "~> 3"
  s.add_development_dependency "rubocop",   "~> 0"
end
