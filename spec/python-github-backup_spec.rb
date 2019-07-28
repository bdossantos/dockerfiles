# frozen_string_literal: true

require 'spec_helper'

describe 'Dockerfile' do
  dockerfile_dir = File.basename(__FILE__)[/(.*)_spec.rb/, 1]
  image = Docker::Image.build_from_dir("#{DOCKERFILES}/#{dockerfile_dir}/")
  puts "#{DOCKERFILES}/#{dockerfile_dir}/"

  set :os, family: :debian
  set :backend, :docker
  set :docker_image, image.id

  describe file('/usr/local/bin/github-backup') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 755 }
    its(:sha256sum) {
      should eq \
        '6501decc09dd7447e982ed30a2748ed70cd1094606fda8cbb0ca2cf405c411db'
    }
  end

  describe command('/usr/local/bin/radicale --help') do
    its(:exit_status) { should eq 0 }
  end
end
