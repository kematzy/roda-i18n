spec = Gem::Specification.new do |s|
  s.name = 'roda-i18n'
  s.version = '0.1.1'
  s.date = '2015-10-21'
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.md", "MIT-LICENSE"]
  s.rdoc_options += ["--quiet", "--line-numbers", "--inline-source", '--title', 'Roda-i18n: internationalisation plugin', '--main', 'README.md']
  s.summary = "Roda Internationalisation plugin"
  s.author = "Kematzy"
  s.email = "kematzy@gmail.com"
  s.homepage = "http://github.com/kematzy/roda-i18n"
  s.files = %w(MIT-LICENSE README.md Rakefile) + Dir["{spec,lib}/**/*.rb"] + Dir["spec/**/*.yml"]
  s.license = 'MIT'
  s.description = "The Roda-i18n plugin enables easy addition of internationalisation (i18n) and localisation support in Roda apps"
  
  s.add_runtime_dependency 'roda', '~> 2.5', '>= 2.5.0'
  s.add_runtime_dependency 'tilt'  
  s.add_runtime_dependency "r18n-core", '~> 2.0', '>= 2.0.3'
  
  s.add_development_dependency 'bundler', "~> 1.10"
  s.add_development_dependency 'rake', "~> 10.0"
  s.add_development_dependency 'erubis'
  s.add_development_dependency 'kramdown'
  s.add_development_dependency "minitest", '~> 5.7', '>= 5.7.0'
  s.add_development_dependency "minitest-hooks", '~> 1.1', '>= 1.1.0'
  s.add_development_dependency 'minitest-rg'
  s.add_development_dependency "rack-test", '~> 0.6.3'
  s.add_development_dependency 'nokogiri'
  s.add_development_dependency 'simplecov'
  
end
