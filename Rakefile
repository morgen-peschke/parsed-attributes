require 'rake/testtask'

namespace :test do
  desc 'Run tests on attribute helper'
  task :attributes do
    Dir['./test/attributes/**/*.rb'].each {|f| require f}
  end

  desc 'Run tests on parsers'
  task :parsers do
    Dir['./test/parsers/**/*.rb'].each {|f| require f}
  end

  task :all => [:attributes, :parsers]
end

desc 'Run all tests'
task test: 'test:all'

task default: :test
