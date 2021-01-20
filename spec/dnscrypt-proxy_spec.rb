# frozen_string_literal: true

require 'spec_helper'
require 'securerandom'

describe 'Dockerfile' do
  dockerfile_dir = File.basename(__FILE__)[/(.*)_spec.rb/, 1]
  image = Docker::Image.build_from_dir("#{DOCKERFILES}/#{dockerfile_dir}/")

  set :os, family: :debian
  set :backend, :docker
  set :docker_image, image.id

  describe command('/usr/local/bin/dnscrypt-proxy -version') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should eq "2.0.45\n" }
  end

  describe file('/usr/local/bin/dnscrypt-proxy') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 755 }
    its(:sha256sum) {
      should eq \
        '6db19271abac32e9e345056197702e001070fb9808339da3de2b2b37b90b5c4a'
    }
  end

  describe file('/etc/dnscrypt-proxy.toml') do
    it { should be_file }
    it { should be_owned_by 'root' }
    its(:sha256sum) {
      should eq \
        'd1f18e2113dce292ba5b9455718cbc3d1ebeaee89dc085ef2c0e718360a3bc54'
    }
  end

  describe command('dig +time=5 +tries=1 @127.0.0.1 -p 53 localhost') do
    its(:exit_status) { should eq 0 }
    its(:stdout) {
      should contain('QUERY: 1, ANSWER: 0, AUTHORITY: 0, ADDITIONAL: 1')
    }
  end

  describe command('dig +time=5 +tries=1 @127.0.0.1 -p 53 bds.io') do
    its(:exit_status) { should eq 0 }
    its(:stdout) {
      should contain('status: NOERROR')
      should contain('QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1')
    }
  end

  describe command("dig +time=5 +tries=1 @127.0.0.1 -p 53 #{SecureRandom.hex}") do
    its(:exit_status) { should eq 0 }
    its(:stdout) {
      should contain('status: NXDOMAIN')
    }
    its(:stdout) {
      should contain('QUERY: 1, ANSWER: 0, AUTHORITY: 0, ADDITIONAL: 1')
    }
  end

  describe command('dig +time=5 +tries=1 @127.0.0.1 -p 53 $(shuf -n 1 /etc/dnscrypt-proxy-blocklist.txt)') do
    its(:exit_status) { should eq 0 }
    its(:stdout) {
      should contain('status: NOERROR')
    }
    its(:stdout) {
      should contain('QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1')
    }
    its(:stdout) {
      should contain('This query has been locally blocked" "by dnscrypt-proxy')
    }
  end
end
