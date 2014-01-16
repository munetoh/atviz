require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = "atviz"
  gem.homepage = "http://github.com/munetoh/atviz"
  gem.license = "MIT"
  gem.summary = %Q{Visualize Attack Tree.}
  gem.description = %Q{TBD}
  gem.email = "munetoh@nii.ac.jp"
  gem.authors = ["Seiji Munetoh"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new


require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

require 'rubocop/rake_task'
desc 'Run RuboCop on the lib directory'
Rubocop::RakeTask.new(:rubocop) do |task|
  task.patterns = [
    'lib/*.rb',
    'spec/*.rb',
    'spec/*/*.rb'
  ]
  # only show the files with failures
  #task.formatters = ['files']
  # don't abort rake on failure
  task.fail_on_error = false
end
