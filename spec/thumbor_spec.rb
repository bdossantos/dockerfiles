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
        '38f018a8994e5cf298a112f1a500efb4a28618849c2bbfc08478d80b1a3f84d9'
    }
  end

  describe file('/usr/bin/jpegtran') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 755 }
    its(:sha256sum) {
      should eq \
        '4d1825f4e58d6264c186fa31fc9ebecdc4de8f217224a10a993941616682379f'
    }
  end
end
