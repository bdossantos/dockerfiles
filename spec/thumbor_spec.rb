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
        '53bb230c8cd682b9a9e528c482cf28b1385da09ccc1ef31453771671965d8dc8'
    }
  end

  describe file('/usr/bin/jpegtran') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 755 }
    its(:sha256sum) {
      should eq \
        '407329018ec7e02dbc3d323ba652fffc986f5776245456cc91e9fa3d28434db5'
    }
  end
end
