# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'bitwise_attribute/version'

Gem::Specification.new do |spec|
  spec.required_ruby_version = '>= 2.5.0'
  spec.name          = 'bitwise_attribute'
  spec.version       = BitwiseAttribute::VERSION
  spec.authors       = ['Ricardo Otero']
  spec.email         = ['oterosantos@gmail.com']

  spec.summary       = 'Bitwise attribute for ruby class and Rails model.'
  spec.description   = 'Bitwise attribute for ruby class and Rails model.'
  spec.homepage      = 'https://github.com/rikas/bitwise_attribute'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = %w[lib]

  spec.add_development_dependency 'activerecord', '>= 3'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rake'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'sqlite3'
end
