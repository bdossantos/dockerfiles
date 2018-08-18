# frozen_string_literal: true

require 'spec_helper'

describe 'Dockerfile' do
  dockerfile_dir = File.basename(__FILE__)[/(.*)_spec.rb/, 1]
  image = Docker::Image.build_from_dir("#{DOCKERFILES}/#{dockerfile_dir}/")

  set :os, family: :debian
  set :backend, :docker
  set :docker_image, image.id

  describe file('/usr/bin/radicale') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 755 }
    its(:sha256sum) {
      should eq \
        '408c1fdebf8060d5e1ff13c4e1125ab918dfc614dda8c1daa8915a76fedc8e4b'
    }
  end

  describe file('/config/radicale.cfg') do
    it { should be_file }
    it { should be_owned_by 'root' }
    its(:sha256sum) {
      should eq \
        '14c662e27dbb6ff6604d2a59ead9cfb6688122578ec00e75aaa42fd6f345b10f'
    }
    it { should contain('hosts = 0.0.0.0:5232, [::]:5232') }
    it { should contain('daemon = False') }
    it { should contain('pid =') }
    it { should contain('max_connections = 20') }
    it { should contain('max_content_length = 100000000') }
    it { should contain('timeout = 10') }
    it { should contain('dns_lookup = True') }
    it { should contain('type = htpasswd') }
    it { should contain('htpasswd_filename = /config/users') }
    it { should contain('htpasswd_encryption = bcrypt') }
    it { should contain('delay = 1') }
    it { should contain('type = owner_only') }
    it { should contain('type = multifilesystem') }
    it { should contain('filesystem_folder = /data/collections') }
    it { should contain('mask_passwords = True') }
  end

  describe command('curl --fail -s http://127.0.0.1:5232/.web') do
    its(:exit_status) { should eq 0 }
  end

  describe port(5232) do
    it { should be_listening.with('tcp') }
  end
end
