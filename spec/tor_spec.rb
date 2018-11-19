# frozen_string_literal: true

require 'spec_helper'

describe 'Dockerfile' do
  dockerfile_dir = File.basename(__FILE__)[/(.*)_spec.rb/, 1]
  image = Docker::Image.build_from_dir("#{DOCKERFILES}/#{dockerfile_dir}/")

  set :os, family: :debian
  set :backend, :docker
  set :docker_image, image.id

  %w[
    autoconf
    automake
    build-essential
    ca-certificates
    dirmngr
    gnupg
    libevent-dev
    libssl-dev
    libtool
    make
    net-tools
    openssl
    pwgen
    wget
    zlib1g
    zlib1g-dev
  ].each do |p|
    describe package(p) do
      it { should be_installed }
    end
  end

  describe command('/usr/local/bin/tor --version') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should eq "Tor version 0.3.4.9 (git-4ac3ccf2863b86e7).\n" }
  end

  describe file('/usr/local/bin/tor') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 755 }
    its(:sha256sum) {
      should eq \
        'ce37dbc434a33c2bfed3b3670859332fa6995dddef80f34c614ac3bb38323c9b'
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
        '8856250dda5206980d058e31163f7e05acc2f5c9de8c4da62440904508c0293a'
    }
  end

  describe file('/etc/tor/torrc') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 444 }
    its(:sha256sum) {
      should eq \
        '4ff1320f38b552b654ad5cf63cefc2d8c1aecbdd1abe5659cdbfa115973121be'
    }
    it { should contain('AutomapHostsOnResolve 1') }
    it { should contain('AutomapHostsSuffixes .exit,.onion') }
    it { should contain('AvoidDiskWrites 1') }
    it { should contain('ClientOnly 1') }
    it { should contain('DNSPort 0.0.0.0:9053') }
    it { should contain('DataDirectory /dev/shm/.tor') }
    it {
      should contain('ExitNodes {fr},{ch},{de},{nl},{se},{no},{fi},{es},{cz}')
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

  describe port(9050) do
    it { should be_listening.with('tcp') }
  end

  describe port(9053) do
    it { should be_listening.with('udp') }
  end
end
