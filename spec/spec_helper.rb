# frozen_string_literal: true

require 'docker'
require 'serverspec'
require 'spec_helper'

set :backend, :exec
set :request_pty, true

DOCKERFILES = './dockerfiles'
