Gem::Specification.new do |s|
  s.name = 'eksek'
  s.version = '0.1.0'
  s.authors = ['Johnny Lee-Othon', 'Thomas Bretzke']
  s.homepage = 'https://github.com/taccon/eksek'
  s.summary = 'A better backticks'
  s.description = <<~END
    Execute shell commands and easily get stdout, stderr, exit code, and more
  END
  s.license = 'ISC'

  s.files = Dir['.gemspec', 'lib/**/*.rb', 'license.txt', 'readme.md']

  s.required_ruby_version = '~> 2.3'
  s.add_development_dependency 'rspec','~> 3'
  s.add_development_dependency 'rubocop', '~> 0.49.0'
end
