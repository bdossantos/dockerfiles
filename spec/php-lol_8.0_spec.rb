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
        '965aaa31790bc615289686a5deec3a823fd2cea4cf7d49879d435e00d1ce8f7f'
    }
  end

  describe file('/usr/local/bin/php') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 755 }
    its(:sha256sum) {
      should eq \
        '81cb67986f679fb4c70d2d2db2c20de338925ead7902e34144a6b2aa6915a317'
    }
  end

  describe file('/usr/local/sbin/php-fpm') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 755 }
    its(:sha256sum) {
      should eq \
        '5bca41823ca6211ce33e63d70f2ea41f92f5f6662deb614c42ade50b8f67a210'
    }
  end

  describe file('/usr/local/etc/php/php.ini') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 444 }
    its(:sha256sum) {
      should eq \
        '200e72b746087c39d723b0d11b41fb94b55988dda017191ea2445d27cae195ec'
    }
  end

  describe file('/usr/local/etc/php/conf.d/zzz-apcu.ini') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 444 }
    its(:sha256sum) {
      should eq \
        'd89f0a34e79a7389c2522b77d5200e88262d1c5ccb926062cb56924520d4cc60'
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
        '6c954557d295a659ef61cccbad334e1cd0670cc0c30bb01694693e3d09a3ca7b'
    }
  end

  describe file('/usr/local/etc/php/conf.d/zzz-php-hardening.ini') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 444 }
    its(:sha256sum) {
      should eq \
        '489ba97dca079d84e7dc21afb68b0acf7954da8ad150279be70053dce7243f83'
    }
  end

  describe file('/etc/nginx/nginx.conf') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 444 }
    its(:sha256sum) {
      should eq \
        'd2b68ea82bfb51b41a65ea1c7ab7f8775649c4f24c54def5d43e244c09b8e276'
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
        '58c9ac10c9be083a55681f2b4166a92c22fee3a7c35157da9dd25716556dc4ee'
    }
  end

  describe file('/etc/supervisor/conf.d/app.conf') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 444 }
    its(:sha256sum) {
      should eq \
        'bbdd21d87a9b30770de6b434673caf6594eb67bc4ff5c124f8c0ccb453c62d6b'
    }
  end

  # FIXME: install geoip
  %w[
    apcu
    bcmath
    bz2
    exif
    gd
    iconv
    igbinary
    imap
    imagick
    intl
    mbstring
    memcached
    pcntl
    pdo_mysql
    pdo_pgsql
    pgsql
    posix
    redis
    soap
    sockets
    sodium
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
  ].each do |geoip|
    describe file("/usr/share/GeoIP/#{geoip}") do
      it { should be_file }
      it { should be_mode 644 }
    end
  end
end
