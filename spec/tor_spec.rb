# frozen_string_literal: true

require 'spec_helper'

describe 'Dockerfile' do
  dockerfile_dir = File.basename(__FILE__)[/(.*)_spec.rb/, 1]
  image = Docker::Image.build_from_dir("#{DOCKERFILES}/#{dockerfile_dir}/")

  set :os, family: :debian
  set :backend, :docker
  set :docker_image, image.id

  %w[
    ca-certificates
    openssl
    wget
    zlib1g
  ].each do |p|
    describe package(p) do
      it { should be_installed }
    end
  end

  describe command('/usr/local/bin/tor --version') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should eq "Tor version 0.4.1.5.\n" }
  end

  describe file('/usr/local/bin/tor') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 755 }
    its(:sha256sum) {
      should eq \
        '25b8b540e4d6c6e56ce4b72469c476a2a2cf82e27e474a458647224b4efbdf98'
    }
  end

  describe command('torify wget -q -O - https://check.torproject.org/') do
    its(:exit_status) { should eq 0 }
    its(:stdout) {
      should contain('Congratulations. This browser is configured to use Tor.')
    }
  end

  describe command('tor-resolve bds.io') do
    its(:exit_status) { should eq 0 }
  end

  describe command('tor-resolve -x 8.8.8.8') do
    its(:exit_status) { should eq 0 }
  end

  describe file('/usr/local/etc/tor/torrc.sample') do
    it { should be_file }
    it { should be_owned_by 'root' }
    its(:sha256sum) {
      should eq \
        '2ab4e318a11d64f4662e0ed5e45630a95de0a86c5a1b6b2425fa9b45f974a880'
    }
  end

  describe file('/etc/tor/torrc') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 444 }
    its(:sha256sum) {
      should eq \
        'd869589e8c7c49972c445f40a7f14c2c6b32ad17055160052ce75fa79c95349e'
    }
    it { should contain('AutomapHostsOnResolve 1') }
    it { should contain('AutomapHostsSuffixes .exit,.onion') }
    it { should contain('AvoidDiskWrites 1') }
    it { should contain('ClientOnly 1') }
    it { should contain('DNSPort 0.0.0.0:9053') }
    it { should contain('DataDirectory /dev/shm/.tor') }
    it {
      should contain('ExcludeNodes {au},{ca},{cn},{cu},{fr},{gb},{hk},{ir},{iq},{kr},{kp},{nz},{ro},{ru},{sy},{tr},{us}')
    }
    it {
      should contain('ExitNodes {be},{ch},{de},{es},{gr},{is},{it},{nl},{se},{no},{fi},{es},{pt}')
    }
    it { should contain('FascistFirewall 1') }
    it { should contain('Log notice stdout') }
    it { should contain('NumCPUs 2') }
    it { should contain('ReachableAddresses *:80,*:443') }
    it { should contain('RunAsDaemon 0') }
    it { should contain('SafeLogging 1') }
    it { should contain('SocksPort 0.0.0.0:9050') }
    it { should contain('StrictNodes 1') }
  end
end
