# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'block_registry/version'

Gem::Specification.new do |spec|
  spec.name          = 'block_registry'
  spec.version       = BlockRegistry::VERSION
  spec.authors       = ['Matt Huggins']
  spec.email         = ['matt.huggins@kapost.com']

  spec.summary       = 'Simple event handler registry'
  spec.description   = 'Register event handlers to key lookups.'
  spec.homepage      = 'https://github.com/kapost/block_registry'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
end
