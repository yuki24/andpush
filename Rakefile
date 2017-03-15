require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/**/*_test.rb']
end

desc 'Generate an API client with the oven gem (the cmd overrides the client if it already exists)'
task :generate do
  sh "ruby -roven fcm.apispec && rubocop -a lib/"
end

task :default => :test
