require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:spec) do |t|
  t.libs << 'spec'
  t.libs << 'lib'
  t.test_files = FileList['spec/**/*_spec.rb']
end

task :default => :spec

desc 'Run specs with coverage'
task :coverage do
  ENV['COVERAGE'] = '1'
  Rake::Task['spec'].invoke
end

desc 'Run Rubocop report'
task :rubocop do
  res = `which rubocop`
  if res != ""
    `rubocop -f html -o ./rubocop/report.html lib/`
  else
    puts "\nERROR: 'rubocop' gem is not installed or available. Please install with 'gem install rubocop'."
  end
end
