# frozen_string_literal: true

require 'spec_helper'

describe 'Dockerfile' do
  dockerfile_dir = File.basename(__FILE__)[/(.*)_spec.rb/, 1]
  image = Docker::Image.build_from_dir("#{DOCKERFILES}/#{dockerfile_dir}/")
  puts "#{DOCKERFILES}/#{dockerfile_dir}/"

  set :os, family: :debian
  set :backend, :docker
  set :docker_image, image.id

  # TODO
end
