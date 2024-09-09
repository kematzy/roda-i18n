# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'rake/testtask'

RuboCop::RakeTask.new

Rake::TestTask.new(:spec) do |t|
  t.libs << 'spec'
  t.libs << 'lib'
  t.test_files = FileList['spec/**/*_spec.rb']
end

task default: %i[rubocop spec]

desc 'alias for spec task'
task test: :spec

desc 'Run specs with coverage'
task :coverage do
  ENV['COVERAGE'] = '1'
  Rake::Task['spec'].invoke
  # `open coverage/index.html` # if OSX
end
