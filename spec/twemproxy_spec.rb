# frozen_string_literal: true

require 'spec_helper'

describe 'Dockerfile' do
  dockerfile_dir = File.basename(__FILE__)[/(.*)_spec.rb/, 1]
  image = Docker::Image.build_from_dir("#{DOCKERFILES}/#{dockerfile_dir}/")

  set :os, family: :debian
  set :backend, :docker
  set :docker_image, image.id

  describe command('/usr/local/sbin/nutcracker -V') do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should contain('This is nutcracker-0.5.0') }
  end

  describe file('/usr/local/sbin/nutcracker') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 755 }
    its(:sha256sum) {
      should eq \
        '7cc863ba9c340a0116ec4222b847a7516b5b3bc19627cf8c270c88e625fced78'
    }
  end
end
