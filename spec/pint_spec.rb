# frozen_string_literal: true

require 'spec_helper'
require 'securerandom'

describe 'Dockerfile' do
  dockerfile_dir = File.basename(__FILE__)[/(.*)_spec.rb/, 1]
  image = Docker::Image.build_from_dir("#{DOCKERFILES}/#{dockerfile_dir}/")

  set :os, family: :debian
  set :backend, :docker
  set :docker_image, image.id

  describe command('/usr/local/bin/pint -version') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should eq "v0.22.2 (revision: fc520ff9f8b6931b58a0eafd02675fc3e7d68493)\n" }
  end
end
