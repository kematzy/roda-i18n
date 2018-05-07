# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'roda/i18n/version'

Gem::Specification.new do |spec|
  spec.name           = 'roda-i18n'
  spec.version        = ::Roda::I18n::VERSION
  spec.authors        = ['Kematzy']
  spec.email          = ['kematzy@gmail.com']
  
  spec.summary        = 'Roda Internationalisation plugin'
  spec.description    = "The Roda-i18n plugin enables easy addition of internationalisation (i18n) and localisation support in Roda apps"
  spec.homepage       = 'http://github.com/kematzy/roda-i18n'
  spec.license        = 'MIT'
  
  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  # end

  spec.files          = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir         = "exe"
  spec.executables    = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths  = ["lib"]
  
  spec.platform         = Gem::Platform::RUBY
  spec.has_rdoc         = true
  spec.extra_rdoc_files = ['README.md', "MIT-LICENSE"]
  spec.rdoc_options     += ['--quiet', '--line-numbers', '--inline-source', '--title', 'Roda-i18n: internationalisation plugin', '--main', 'README.md']
  
  spec.add_runtime_dependency 'roda', '~> 3.7'
  spec.add_runtime_dependency 'tilt'  
  spec.add_runtime_dependency 'r18n-core', '~> 3.0'
  
  spec.add_development_dependency 'bundler', "~> 1.10"
  spec.add_development_dependency 'rake', "~> 12.3"
  spec.add_development_dependency 'erubis'
  spec.add_development_dependency 'kramdown'
  spec.add_development_dependency 'minitest', '~> 5.7', '>= 5.7.0'
  spec.add_development_dependency 'minitest-assert_errors'
  spec.add_development_dependency 'minitest-hooks', '~> 1.1', '>= 1.1.0'
  spec.add_development_dependency 'minitest-rg'
  spec.add_development_dependency 'rack-test', '~> 1.0'
  spec.add_development_dependency 'nokogiri'
  spec.add_development_dependency 'simplecov'
  
end
