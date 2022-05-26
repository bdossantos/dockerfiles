# frozen_string_literal: true

require 'spec_helper'

describe 'Dockerfile' do
  dockerfile_dir = File.basename(__FILE__)[/(.*)_spec.rb/, 1]
  image = Docker::Image.build_from_dir("#{DOCKERFILES}/#{dockerfile_dir}/")
  puts "#{DOCKERFILES}/#{dockerfile_dir}/"

  set :os, family: :debian
  set :backend, :docker
  set :docker_image, image.id

  describe file('/app/bin/paperless-ng') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 755 }
    its(:sha256sum) {
      should eq \
        '2456d1e5f6d23920b487c28e366b68addb1ab07b2fad9f44d27779709dacba5b'
    }
  end

  describe command('curl --fail -s http://127.0.0.1:8000') do
    its(:exit_status) { should eq 0 }
  end
end
