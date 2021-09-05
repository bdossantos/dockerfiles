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
    ffmpeg
    gifsicle
    graphicsmagick
    libjpeg-turbo-progs
    webp
  ].each do |p|
    describe package(p) do
      it { should be_installed }
    end
  end

  describe file('/app/bin/thumbor') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 755 }
    its(:sha256sum) {
      should eq \
        'a5deb3a8942f30059604a643c4908f8c0d46279fa1a7b77ea0dd41babdff1690'
    }
  end

  describe file('/usr/bin/jpegtran') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 755 }
    its(:sha256sum) {
      should eq \
        '9aa3694a8991a57bc7ca8913fe7a0cb9ebbbf84287a92432bb6303218021204e'
    }
  end

  describe command('/app/bin/thumbor-doctor') do
    its(:exit_status) { should eq 0 }
  end
end
