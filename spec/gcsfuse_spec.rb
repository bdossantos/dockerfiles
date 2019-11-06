# frozen_string_literal: true

require 'spec_helper'

describe 'Dockerfile' do
  dockerfile_dir = File.basename(__FILE__)[/(.*)_spec.rb/, 1]
  image = Docker::Image.build_from_dir("#{DOCKERFILES}/#{dockerfile_dir}/")

  set :os, family: :debian
  set :backend, :docker
  set :docker_image, image.id
  set :docker_container_create_options, 'Entrypoint' => ['sleep', 'infinity']

  %w[
    gcsfuse
  ].each do |p|
    describe package(p) do
      it { should be_installed }
    end
  end

  describe command('/usr/bin/gcsfuse --version') do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq "gcsfuse version 0.28.1 (Go version go1.9.7)\n" }
  end

  describe file('/usr/bin/gcsfuse') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 775 }
    its(:sha256sum) {
      should eq \
        'd29ed5f634319d5ab07a646b9e3333171d9b1d93c76c2337c67eb11af921d4c3'
    }
  end
end
