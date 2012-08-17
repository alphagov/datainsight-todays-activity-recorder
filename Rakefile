require 'rubygems'
require 'rspec/core/rake_task'
require 'ci/reporter/rake/rspec'

task :default => :spec

RSpec::Core::RakeTask.new do |task|
  task.pattern = 'spec/**/*_spec.rb'
  task.rspec_opts = ["--format documentation"]
end

namespace :spec do
  desc "Run RSpec unit code examples"
  RSpec::Core::RakeTask.new (:unit) do |task|
    task.pattern = "spec/unit/*_spec.rb"
    task.rspec_opts = ["--format documentation"]
  end

  desc "Run RSpec functional code examples"
  RSpec::Core::RakeTask.new(:functional) do |task|
    task.pattern = "spec/functional/*_spec.rb"
    task.rspec_opts = ["--format documentation"]
  end
end
