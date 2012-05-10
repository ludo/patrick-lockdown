require 'rubygems'
require 'rake'

require File.join(File.dirname(__FILE__), "lib", "lockdown")

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "lockdown"
    gem.version = Lockdown.version
    gem.rubyforge_project = "lockdown"
    gem.summary = "Authorization system for Rails"
    gem.description = "Restrict access to your controller actions. "
    gem.email = "andy@stonean.com"
    gem.homepage = "https://github.com/ludo/patrick-lockdown"
    gem.authors = ["Andrew Stone", "Patrick Baselier"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new do |t|
    t.files   = FileList['lib/**/*.rb']
    t.options = ['-r'] # optional
  end
rescue LoadError
  task :yard do
    abort "YARD is not available. In order to run yard, you must: sudo gem install yard"
  end
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install rcov"
  end
end

task :default => 'test'
