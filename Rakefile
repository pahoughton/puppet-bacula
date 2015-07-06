# Rakefile - 2014-02-14 17:42
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
require 'rake'
require 'rspec/core/rake_task'
require 'puppet-lint/tasks/puppet-lint'

PuppetLint.configuration.disable_80chars
PuppetLint.configuration.disable_class_parameter_defaults
PuppetLint.configuration.ignore_paths = FileList['**/fixtures/modules/**/**']

desc "Test prep with librarian-puppet"
task :rspec_prep do
 sh "
if [ -d .librarian ] ; then
  echo updating...
  librarian-puppet update;
else
  echo installing...
  librarian-puppet install --path=spec/fixtures/modules/;
fi
"
end

desc "Unit Test"
task :unittest do
 sh "make -C tests unittest"
end

desc "RSpec tests"
RSpec::Core::RakeTask.new(:rspectest) do |t|
#  t.rspec_opts = ['--format=d']
  t.pattern = 'spec/unit/**/*_spec.rb'
end

desc "Unit-suite tests w/o doc"
RSpec::Core::RakeTask.new(:rspectest_nodoc) do |t|
  t.pattern = 'spec/unit-suite/**/*_spec.rb'
end
desc "Unit-suite tests w/ doc"
RSpec::Core::RakeTask.new(:rspectest_suite) do |t|
  t.rspec_opts = ['--format=d']
  t.pattern = 'spec/unit-suite/**/*_spec.rb'
end
