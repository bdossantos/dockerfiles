# frozen_string_literal: true

require 'spec_helper'
require 'securerandom'

describe 'Dockerfile' do
  PHP_VERSION = File.basename(__FILE__)[/php-lol_(.*)_spec.rb/, 1]
  image = Docker::Image.build_from_dir(
    "#{DOCKERFILES}/php-lol/",
    'dockerfile' => "Dockerfile.#{PHP_VERSION}"
  )

  set :os, family: :debian
  set :backend, :docker
  set :docker_image, image.id

  describe command('/usr/local/sbin/php-fpm -t') do
    its(:exit_status) { should eq 0 }
  end

  describe command('/usr/sbin/nginx -t') do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should contain("nginx: the configuration file /etc/nginx/nginx.conf syntax is ok\n") }
    its(:stderr) { should contain("nginx: configuration file /etc/nginx/nginx.conf test is successful\n") }
  end

  describe file('/usr/sbin/nginx') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 755 }
    its(:sha256sum) {
      should eq \
        '47d578b452a7c6712f89948c9d4c6fd7de658d45f26894c9468359530d5e817d'
    }
  end

  describe file('/usr/local/bin/php') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 755 }
    its(:sha256sum) {
      should eq \
        '5cbc87e0d60e9f18938b914fdf5a14acae13b3ef08eca3010ae5557351609ba2'
    }
  end

  describe file('/usr/local/sbin/php-fpm') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 755 }
    its(:sha256sum) {
      should eq \
        'd791ac294cf79d7e35c5fb79355a46d12619dd4da10c75410beb3af47951a96a'
    }
  end

  describe file('/usr/local/etc/php/php.ini') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 444 }
    its(:sha256sum) {
      should eq \
        'ca1b41da9c03a2230cfde8557773c66247d82caa717cb692553c1a67e45dc10b'
    }
  end

  describe file('/usr/local/etc/php/conf.d/zzz-opcache.ini') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 444 }
    its(:sha256sum) {
      should eq \
        'e1137b3fe6413c11f9991ee422ad36d811d622b0eabdc055cc63871ad9bff52a'
    }
  end

  describe file('/usr/local/etc/php-fpm.d/zzz-php-fpm-tuning.conf') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 444 }
    its(:sha256sum) {
      should eq \
        '8d66499c0763b5b8ada019917cf90ec78afe886dd644b0d702c1f84fd23ad157'
    }
  end

  describe file('/usr/local/etc/php/conf.d/zzz-php-hardening.ini') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 444 }
    its(:sha256sum) {
      should eq \
        '4baf5c2ced888290b26bb00e82ee6a091052ab333f9654e0cf1da67c03b07d41'
    }
  end

  describe file('/etc/nginx/nginx.conf') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 444 }
    its(:sha256sum) {
      should eq \
        'cb6dcc8b96f089a4a6689b529a808adef5133cd041f4a84b60eab9a470268d7d'
    }
  end

  describe file('/etc/nginx/mime.types') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 444 }
    its(:sha256sum) {
      should eq \
        'ac27e1f587ecebc46ded3265479efdc6cb2f711c22e8221dadb00b7b4db55369'
    }
  end

  describe file('/etc/supervisord.conf') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 444 }
    its(:sha256sum) {
      should eq \
        '05cb70c7ecd2b75dce241d5cc0b1174fa5121b52fd8ba5f6134c5b1bc9fcf8bc'
    }
  end

  describe file('/etc/supervisor/conf.d/app.conf') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 444 }
    its(:sha256sum) {
      should eq \
        'be6a906880879641e05c8719e9d1f7f7daeb7556ab37a7bae3eae4b118506b0f'
    }
  end

  %w[
    bcmath
    exif
    gd
    geoip
    iconv
    igbinary
    intl
    mbstring
    memcached
    pdo_mysql
    pdo_pgsql
    pgsql
    posix
    redis
    soap
    sockets
    tidy
    zip
  ].each do |extension|
    describe command("php -m | grep -i #{extension}") do
      its(:exit_status) { should eq 0 }
      its(:stdout) {
        should contain(extension)
      }
    end
  end

  %w[
    GeoIP.dat
    GeoIPv6.dat
    GeoLite2-ASN.mmdb
    GeoLite2-City.mmdb
    GeoLite2-Country.mmdb
  ].each do |geoip|
    describe file("/usr/share/GeoIP/#{geoip}") do
      it { should be_file }
      it { should be_mode 644 }
    end
  end
end
