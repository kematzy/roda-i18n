# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'roda/i18n/version'

Gem::Specification.new do |spec|
  spec.name           = 'roda-i18n'
  spec.version        = Roda::I18n::VERSION
  spec.authors        = ['Kematzy']
  spec.email          = ['kematzy@gmail.com']

  spec.summary        = 'Roda Internationalisation plugin'
  spec.description    = 'The Roda-i18n plugin enables easy addition of internationalisation (i18n) and localisation support in Roda apps'
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
  spec.bindir         = 'exe'
  spec.executables    = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths  = ['lib']

  spec.platform         = Gem::Platform::RUBY
  spec.extra_rdoc_files = ['README.md', 'MIT-LICENSE']
  spec.rdoc_options += ['--quiet', '--line-numbers', '--inline-source', '--title',
                        'Roda-i18n: internationalisation plugin', '--main', 'README.md']

  spec.required_ruby_version = '>= 3.0.0'

  spec.add_dependency 'date'
  spec.add_dependency 'r18n-core', '~> 5.0'
  spec.add_dependency 'roda', '~> 3.8'
  spec.add_dependency 'tilt'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
