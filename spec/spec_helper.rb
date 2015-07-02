require 'rspec-puppet'

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))

RSpec.configure do |c|
  c.module_path = File.join(fixture_path, 'modules')
  c.manifest_dir = File.join(fixture_path, 'manifests')
  c.environmentpath = File.join(Dir.pwd, 'spec')
  c.hiera_config = 'spec/fixtures/hiera/hiera.yaml'
  c.fail_fast     = true
  c.default_facts = {
    :root_home      => '/root',
    :kernel         => 'Linux',
  }
end
