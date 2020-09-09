# encoding: UTF-8
lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'spree_promese/version'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_promese'
  s.version     = SpreePromese.version
  s.summary     = 'Connect Spree to Promese'
  s.description = 'Connects your spree store to promese fullfilment'
  s.required_ruby_version = '>= 2.2.7'

  s.author    = 'Fabian Oudhaarlem'
  s.email     = 'fabian@oldharlem.nl'
  s.homepage  = 'https://github.com/Oldharlem/spree_promese'
  s.license = 'BSD-3-Clause'

  s.files       = `git ls-files`.split("\n").reject { |f| f.match(/^spec/) && !f.match(/^spec\/fixtures/) }
  s.require_path = 'lib'
  s.requirements << 'none'

  spree_version = '>= 3.1.0', '< 5.0'
  s.add_dependency 'spree_core', spree_version
  s.add_dependency 'spree_api', spree_version
  s.add_dependency 'spree_backend', spree_version
  s.add_dependency 'spree_extension'

  s.add_development_dependency 'spree_dev_tools'
  s.add_development_dependency 'sqlite3', '~> 1.3.6'
end
