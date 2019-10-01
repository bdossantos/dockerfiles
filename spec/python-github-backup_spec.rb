# frozen_string_literal: true

require 'spec_helper'

describe 'Dockerfile' do
  dockerfile_dir = File.basename(__FILE__)[/(.*)_spec.rb/, 1]
  image = Docker::Image.build_from_dir("#{DOCKERFILES}/#{dockerfile_dir}/")
  puts "#{DOCKERFILES}/#{dockerfile_dir}/"

  set :os, family: :debian
  set :backend, :docker
  set :docker_image, image.id
  set :docker_container_create_options, 'Entrypoint' => ['sleep', 'infinity']

  describe file('/usr/local/bin/github-backup') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 755 }
    its(:sha256sum) {
      should eq \
        '91f9a02d3a855d3defd70ae88f2c284bbdc94a980629a2d233b6c9a76090e3c7'
    }
  end

  describe command('/usr/local/bin/github-backup --help') do
    its(:exit_status) { should eq 0 }
  end
end
