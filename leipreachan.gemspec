# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'leipreachan/version'

Gem::Specification.new do |spec|
  spec.name          = "leipreachan"
  spec.version       = Leipreachan::VERSION
  spec.authors       = ["Anadea Inc team (http://anadea.info)"]
  spec.email         = ["gemmaker@anahoret.com"]

  spec.summary       = %q{Backup and restore your database by the simple way.}
  spec.description   = %q{Backup and restore your database as simple as posible.}
  spec.homepage      = "https://github.com/anadea/leipreachan"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', "~> 1.9"
  spec.add_development_dependency 'rake', "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency 'railties'
  spec.add_development_dependency "rails"
  spec.add_development_dependency "activerecord"
end
