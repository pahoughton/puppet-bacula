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

desc "get modules for rspec test"
task :rspecprep do
 sh "
puppet module install --target-dir spec/fixtures/modules  puppetlabs-postgresql
"
end

desc "Unit Test"
task :systest do
 sh "make -C tests unittest DEBUG=true"
end

desc "test a specific spec file linked in spec/unit"
RSpec::Core::RakeTask.new(:rspectest) do |t|
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

desc "Unit-suite tests w/ doc"
RSpec::Core::RakeTask.new(:rspectest_outfile) do |t|
  t.rspec_opts = ['--format=d','--out=unittest-suite-results.txt']
  t.pattern = 'spec/unit-suite/**/*_spec.rb'
end

desc "Generate test results markdown"
task :rspectest_md => [:rspecprep, :rspectest_outfile] do
  sh "outfn=unittest-suite-results.md;
echo '## 'Unit test results - `date` > $outfn;
echo '```' >> $outfn;
cat unittest-suite-results.txt >> $outfn;
echo '```' >> $outfn;
"
end

task :fulltest => [:rspectest_md, :systest] do
  sh "echo fulltest complete."
end
