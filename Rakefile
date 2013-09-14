require 'rake'
require 'rake/testtask'
require File.expand_path('../lib/columbo/version', __FILE__)

Rake::TestTask.new(:test) do |test|
  # TODO: add tests
  test.libs << 'test'
  # test.warning = true
  test.pattern = 'test/**/test_*.rb'
end

task :build do
  system "gem build columbo.gemspec"
end

task :install => :build do
  system "gem install --no-ri --no-rdoc columbo-#{Columbo::VERSION}.gem"
end

task :server do
  system "cd example/sinatra/; ruby app.rb"
end

task :release => :build do
  system "gem push columbo-#{Columbo::VERSION}.gem"
end

task :default => :test
