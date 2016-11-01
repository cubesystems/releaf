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

desc "Run specs and generate coverage report."
task :ci do
  rm_rf "coverage" if File.exist? 'coverage'
  ENV['RAILS_ENV'] = 'test'
  ENV['COVERAGE'] ||= 'y'
  Rake::Task[:spec].invoke
end

namespace :gem do
  def gems
    list =  [{path: Dir.pwd, name: "releaf"}]
    Releaf::GEMS.each{|gem| list << {path: "#{Dir.pwd}/#{gem}", name: gem} }
    list
  end


  desc 'Build all releaf gems'
  task :build do
    gems.each do|options|
      sh "cd #{options[:path]} && gem build #{options[:name]}.gemspec"
      sh "mv #{options[:path]}/#{options[:name]}-#{Releaf::VERSION}.gem #{Dir.pwd}/pkg/"
    end
  end

  desc 'Push all releaf gems'
  task :push do
    gems.each do|options|
      sh "gem push #{Dir.pwd}/pkg/#{options[:name]}-#{Releaf::VERSION}.gem "
    end
  end
end

desc 'Dummy test app tasks'
namespace :dummy do
  desc 'Remove current dummy app'
  task :remove do
    dummy = File.expand_path('../spec/dummy', __FILE__)
    sh "rake db:drop"
    sh "rm -rf #{dummy}"
  end

  desc 'Setup new dummy app'
  task :setup do
    File.expand_path('../spec/dummy', __FILE__)
    gem 'railties'
    require 'rails/generators'
    require 'rails/generators/rails/app/app_generator'
    require 'yaml'

    config_file = File.expand_path('../config.yml', __FILE__)
    config = YAML.load_file(config_file)

    template_path = File.expand_path('../templates/releaf/installer.rb', __FILE__)
    application_name = "spec/dummy"
    result = Rails::Generators::AppGenerator.start [application_name, '-m', template_path, '--skip-gemfile', "--database=#{config['database']['type']}", '--skip-bundle', '--skip-test-unit'] | ARGV
  end
end

APP_RAKEFILE = File.expand_path("../spec/dummy/Rakefile", __FILE__)
if FileTest.exist?(APP_RAKEFILE)
  load 'rails/tasks/engine.rake'
end

Bundler::GemHelper.install_tasks

Dir[File.join(File.dirname(__FILE__), 'tasks/**/*.rake')].each {|f| load f }

require 'rspec/core'
require 'rspec/core/rake_task'

desc "Run all specs in spec directory (excluding plugin specs)"
RSpec::Core::RakeTask.new(spec: 'app:db:test:prepare') do |t|
  t.pattern = "./releaf-*/spec/**/*_spec.rb"
end


task default: :spec
