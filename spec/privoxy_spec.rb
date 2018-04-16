# frozen_string_literal: true

require 'spec_helper'

describe 'Dockerfile' do
  dockerfile_dir = File.basename(__FILE__)[/(.*)_spec.rb/, 1]
  image = Docker::Image.build_from_dir("#{DOCKERFILES}/#{dockerfile_dir}/")

  set :os, family: :debian
  set :backend, :docker
  set :docker_image, image.id

  %w[
    privoxy
  ].each do |p|
    describe package(p) do
      it { should be_installed }
    end
  end

  describe command('/usr/sbin/privoxy --version') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should eq "Privoxy version 3.0.26 (https://www.privoxy.org/)\n" }
  end

  describe file('/usr/sbin/privoxy') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 755 }
    its(:sha256sum) {
      should eq \
        '4bd56895ec800b9905f4f75e67b94843cf9bd2d476b9f7820eef92a212bcb22d'
    }
  end

  describe command('env ALL_PROXY=http://127.0.0.1:8118 curl -s http://p.p/') do
    its(:exit_status) { should eq 0 }
    its(:stdout) {
      should contain('enabled')
    }
  end

  describe command('env ALL_PROXY=http://127.0.0.1:8118 curl -I http://ads.foo.com/') do
    its(:exit_status) { should eq 0 }
    its(:stdout) {
      should contain('403 Request blocked by Privoxy')
    }
  end

  describe command('env ALL_PROXY=http://127.0.0.1:8118 curl -I -L http://imgur.com/') do
    its(:exit_status) { should eq 0 }
    its(:stdout) {
      should contain('302 Local Redirect from Privoxy')
    }
  end

  describe file('/etc/privoxy/config') do
    it { should be_file }
    it { should be_owned_by 'root' }
    its(:sha256sum) {
      should eq \
        '888037f06aaa547b57423267471eff16967c4054979048d2284868875993f73a'
    }
  end

  describe file('/etc/privoxy/user.action') do
    it { should be_file }
    it { should be_owned_by 'root' }
    its(:sha256sum) {
      should eq \
        'fcb42214b4b0aed7dbe70a08e7d5388f632d889a1cae91d400f4fd40e2ca4f65'
    }
  end

  describe port(8118) do
    it { should be_listening.with('tcp') }
  end
end
