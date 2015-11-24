require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:spec) do |t|
  t.libs << "spec"
  t.libs << "lib"
  t.test_files = FileList['spec/**/*_spec.rb']
end

task :default => :spec

desc "Run specs with coverage"
task :coverage do
  ENV['COVERAGE'] = '1'
  Rake::Task['spec'].invoke
end

desc "Run Rubocop report"
task :rubocop do
  `rubocop -f html -o ./Rubocop-report.html lib/`
end
