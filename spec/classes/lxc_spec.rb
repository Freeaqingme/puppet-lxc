require 'spec_helper'

describe 'lxc' do
  it { should include_class("lxc::params") }
  it { should include_class("nginx") }

  it { should contain_package("lxc") }
  it { should contain_package("resolvconf") }

  it do should contain_service("lxc").with(
    :ensure  => 'running',
    :enable  => true,
    :require => 'Package[lxc]'
  ) end

  it do should contain_file("/etc/lxc/guests").with(
    :ensure  => 'directory',
    :require => 'Service[lxc]'
  ) end

  it do should contain_resource("File_line[lxc resolver]").with(
    :ensure  => 'present',
    :line    => 'nameserver 10.0.3.1',
    :path    => '/etc/resolvconf/resolv.conf.d/head',
    :require => 'Service[lxc-net]'
  ) end

  it do should contain_exec("lxc resolvconf").with(
    :command     => '/sbin/resolvconf -u',
    :refreshonly => true,
    :subscribe   => '[File_line[lxc resolver], Package[resolvconf]]'
  ) end

  it do should contain_user("vmguest").with(
    :ensure     => 'present',
    :system     => true,
    :managehome => true,
    :shell      => '/bin/bash',
    :home       => '/home/vmguest',
    :require    => 'Service[lxc]'
  ) end
end
