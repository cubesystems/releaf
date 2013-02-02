#!/usr/bin/env rake
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end
begin
  require 'rdoc/task'
rescue LoadError
  require 'rdoc/rdoc'
  require 'rake/rdoctask'
  RDoc::Task = Rake::RDocTask
end

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Releaf'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.include('app/**/*.rb')
end


desc 'Generates a dummy app for testing'
task :dummy_app => [:setup, :migrate]

task :setup do
  require 'rails'
  require 'releaf'
  relative_path = File.expand_path('../lib/generators/releaf/dummy_generator.rb', __FILE__)
  require relative_path
  #require 'lib/generators/releaf/dummy_generator.rb'
  #
  #https://github.com/radar/forem/blob/master/spec/lib/generators/forem/dummy/dummy_generator.rb

  dummy = File.expand_path('../spec/dummy', __FILE__)
  sh "rm -rf #{dummy}"
  #Releaf::Generators::DummyGenerator.start(
    #%W(. --force --skip-bundle --old-style-hash --dummy-path=#{dummy})
  #)

  gem 'railties'
  require 'rails/generators'
  require 'rails/generators/rails/app/app_generator'
  #generate "settings settings"
  #sh("cd #{dummy} && rails generate releaf:install")
  #
  template_path = File.expand_path('../templates/releaf/installer.rb', __FILE__)
  application_name = "spec/dummy"
  result = Rails::Generators::AppGenerator.start [application_name, '-m', template_path, '--skip-gemfile', '--skip-bundle', '--skip-test-unit', '--dummy-install'] | ARGV
end

task :migrate do
  rakefile = File.expand_path('../spec/dummy/Rakefile', __FILE__)
  sh("rake -f #{rakefile} releaf:install")
  #sh("rake -f #{rakefile} releaf:install")
  #sh("rake -f #{rakefile} releaf:install:migrations")
  #sh("rake -f #{rakefile} db:create db:migrate db:test:prepare")
end

APP_RAKEFILE = File.expand_path("../spec/dummy/Rakefile", __FILE__)
if FileTest.exists?(APP_RAKEFILE)
  load 'rails/tasks/engine.rake'
end

Bundler::GemHelper.install_tasks

Dir[File.join(File.dirname(__FILE__), 'tasks/**/*.rake')].each {|f| load f }

require 'rspec/core'
require 'rspec/core/rake_task'

desc "Run all specs in spec directory (excluding plugin specs)"
RSpec::Core::RakeTask.new(:spec => 'app:db:test:prepare')


task :default => :spec
