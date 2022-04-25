# frozen_string_literal: true

require 'spec_helper'
require 'securerandom'

describe 'Dockerfile' do
  dockerfile_dir = File.basename(__FILE__)[/(.*)_spec.rb/, 1]
  image = Docker::Image.build_from_dir("#{DOCKERFILES}/#{dockerfile_dir}/")

  set :os, family: :debian
  set :backend, :docker
  set :docker_image, image.id

  describe command('/usr/local/bin/resec -version') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should eq "resec version v1.1.2\n" }
  end

  describe file('/usr/local/bin/resec') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 755 }
    its(:sha256sum) {
      should eq \
        '5d064b1648bdbb5ed6bd17f2eed955a1ba9a7141889876c606c02944e1803315'
    }
  end
end
