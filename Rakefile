require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:spec) do |t|
  t.libs << 'spec'
  t.libs << 'lib'
  t.test_files = FileList['spec/**/*_spec.rb']
end

task :default => :spec
task :test => :spec

desc 'Run specs with coverage'
task :coverage do
  ENV['COVERAGE'] = '1'
  Rake::Task['spec'].invoke
    # `open coverage/index.html` # if OSX
end

desc 'Run Rubocop report'
task :rubocop do
  res = `which rubocop`
  if res != ""
    `rubocop -f html -o ./rubocop/report.html lib/`
      # `open rubocop/report.html` # if OSX
  else
    puts "\nERROR: 'rubocop' gem is not installed or available. Please install with 'gem install rubocop'."
  end
end
