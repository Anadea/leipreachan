# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'leipreachan/version'

Gem::Specification.new do |s|
  s.name          = "leipreachan"
  s.version       = Leipreachan::VERSION
  s.authors       = ["Anadea Inc team (http://anadea.info)"]
  s.email         = ["gemmaker@anahoret.com"]

  s.summary       = %q{Backup and restore your database by the simple way.}
  s.description   = %q{Backup and restore your database as simple as posible.}
  s.homepage      = "https://github.com/anadea/leipreachan"
  s.license       = "MIT"

  s.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  s.bindir        = "bin"
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.required_ruby_version = ">= #{Leipreachan::RUBY_VERSION}"

  s.add_dependency 'bundler', '~> 1.3'

  s.add_development_dependency 'rails', ">= #{Leipreachan::RAILS_VERSION}"
  s.add_development_dependency 'rake', "~> 10.0"
  s.add_development_dependency 'rspec', '>= 3.2.0', '<4'
  s.add_development_dependency 'railties', ">= #{Leipreachan::RAILS_VERSION}"
  s.add_development_dependency 'simplecov'
end
