require 'rake/clean'

require 'jasmine-headless-webkit'
require 'jasmine/headless/task'

require 'cucumber'
require 'cucumber/rake/task'

require 'js_rake_tasks'

include Rake::DSL if defined?(Rake::DSL)

CLEAN << "dist"

Jasmine::Headless::Task.new
Cucumber::Rake::Task.new

task :default => ['jasmine:headless', 'cucumber', 'coffee:compile']

