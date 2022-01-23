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

  describe file('/config/radicale.cfg') do
    it { should be_file }
    it { should be_owned_by 'nobody' }
    its(:sha256sum) {
      should eq \
        '766bb94b045bd5f172170046c976f0b30e2e2b997eecf0a817cbdf303ac9102c'
    }
    it { should contain('hosts = 0.0.0.0:5232, [::]:5232') }
    it { should contain('max_connections = 20') }
    it { should contain('max_content_length = 100000000') }
    it { should contain('timeout = 60') }
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
