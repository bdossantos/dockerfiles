# frozen_string_literal: true

require 'spec_helper'

describe 'Dockerfile' do
  dockerfile_dir = File.basename(__FILE__)[/(.*)_spec.rb/, 1]
  image = Docker::Image.build_from_dir("#{DOCKERFILES}/#{dockerfile_dir}/")

  set :os, family: :debian
  set :backend, :docker
  set :docker_image, image.id

  describe file('/usr/local/bin/radicale') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 755 }
    its(:sha256sum) {
      should eq \
        '6432bbe2cc66a77fd749e6971852c4ca8f4ef12f57428e0396a4b37234f0238c'
    }
  end

  describe file('/config/radicale.cfg') do
    it { should be_file }
    it { should be_owned_by 'nobody' }
    its(:sha256sum) {
      should eq \
        '557b2bd1c728719ad86e5aa2fc6e8de1803ea7f193f7bb1f0f9e571ad611bb9d'
    }
    it { should contain('hosts = 0.0.0.0:5232, [::]:5232') }
    it { should contain('daemon = False') }
    it { should contain('pid =') }
    it { should contain('max_connections = 20') }
    it { should contain('max_content_length = 100000000') }
    it { should contain('timeout = 30') }
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
end
