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
        'e02e5ec4ec25ff89fd73324a9226530ce6d8172eb30461a51c4e916bd9c61e62'
    }
  end

  describe file('/usr/local/bin/php') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 755 }
    its(:sha256sum) {
      should eq \
        'e4548e5e7d0ebe74c06f9ed7afe697a1a4484995e3eae6bd101a0885268d6ac0'
    }
  end

  describe file('/usr/local/sbin/php-fpm') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 755 }
    its(:sha256sum) {
      should eq \
        'a162064f5496a4cb30547892246d11e13b21546228ce8f080dccc9cdead1b371'
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
        '0e2525ba3f120894e99bb7beebc0f41cf949361731b2d90fa8bbe273b49864d4'
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
        '563cdddbc20b910401b6d8c0505a03d3c3c886e0f5d3ca3054d5ca116daf476c'
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

  describe file('/etc/supervisor/supervisord.conf') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 444 }
    its(:sha256sum) {
      should eq \
        '09c212cf4d63c17845b7d626a4ddfe8462207e8e056c893fb357a8284c64f21d'
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
