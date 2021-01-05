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

  describe file('/app/bin/github-backup') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 755 }
    its(:sha256sum) {
      should eq \
        '44ca481d23678c5e2e3b742b5a94160020b24f4fe5bb43b23dfae0ccd910db98'
    }
  end

  describe command('/app/bin/github-backup --help') do
    its(:exit_status) { should eq 0 }
  end
end
