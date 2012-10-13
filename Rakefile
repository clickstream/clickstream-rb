require 'rake'
require 'rake/testtask'
require File.expand_path('../lib/colombo',  __FILE__)

Rake::TestTask.new(:test) do |test|
  # TODO: add tests
  test.libs << 'test'
  # test.warning = true
  test.pattern = 'test/**/test_*.rb'
end

task :build do
  system "gem build colombo.gemspec"
end

task :release => :build do
  system "gem push colombo-#{Colombo::VERSION}.gem"
end

task :default => :test
