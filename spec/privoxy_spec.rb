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
    its(:stdout) { should eq "Privoxy version 3.0.28 (https://www.privoxy.org/)\n" }
  end

  describe file('/usr/sbin/privoxy') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 755 }
    its(:sha256sum) {
      should eq \
        '0d816d34612a58b4ac5d19d5d33c1547b76a21852ec58fec680030336dfea0c0'
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
        '543f7edfb340ab56190109e99e22cb6b6038fd8e183fc9c6fc8547de677fb1be'
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
