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
    its(:stderr) { should eq "gcsfuse version 0.32.0 (Go version go1.15.3)\n" }
  end

  describe file('/usr/bin/gcsfuse') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 775 }
    its(:sha256sum) {
      should eq \
        '34ba4badac238a72a1c0d86386b49e9279c1d4e003d8cd529a20def161f802aa'
    }
  end
end
