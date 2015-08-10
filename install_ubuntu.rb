package 'gcc' do
  action :install
  version '4:4.8.2-1ubuntu6'
end

package 'exiftool' do
  action :install
  version '9.46'
end

package 'imagemagick' do
  action :install
  version '8:6.7.7.10-6ubuntu3'
end

package 'ufraw' do
  action :install
  version '0.19.2-2ubuntu2'
end

package 'ruby-mysql' do
  action :install
  version '2.8.2+gem2deb-4'
end

package 'libmagickwand-dev' do
  action :install
  version '8:6.7.7.10-6ubuntu3'
end

package 'ruby-dev' do
  action :install
  version '1:1.9.3.4'
end

gem_package 'sequel' do
  action :install
  version '4.24.0'
end

gem_package 'mini_exiftool' do
  action :install
  version '2.5.1'
end

gem_package 'rmagick' do
  action :install
  version '2.15.3'
end

gem_package 'ruby-mysql' do
  action :install
  version '2.9.13'
end
