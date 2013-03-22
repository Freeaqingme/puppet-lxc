require 'spec_helper'

describe "lxc::vm" do
  let(:title) { 'my-vm' }

  it do should contain_file("/etc/lxc/guests/my-vm.conf").with(
    :ensure  => 'present',
    :content => /512M/,
    :require => 'File[/etc/lxc/guests]'
  ) end

  it do should contain_exec("lxc-create my-vm").with(
    :creates => '/var/lib/lxc/my-vm',
    :command => '/usr/bin/lxc-create -n my-vm -t ubuntu -f /etc/lxc/guests/my-vm.conf',
    :require => 'File[/etc/lxc/guests/my-vm.conf]'
  ) end

  it do should contain_exec("lxc-start my-vm").with(
    :unless  => '/usr/bin/lxc-info -n my-vm | grep state | grep RUNNING',
    :command => '/usr/bin/lxc-start -n my-vm -d',
    :require => 'Exec[lxc-create my-vm]'
  ) end

  it do should contain_file("/etc/lxc/auto/my-vm.conf").with(
    :ensure  => 'link',
    :target  => '/var/lib/lxc/my-vm/config',
    :require => 'Exec[lxc-create my-vm]'
  ) end

  context "with $enable => false" do
    let(:params) { { :enable => false } }

    it do should contain_file("/etc/lxc/auto/my-vm.conf").with(
      :ensure => 'absent'
    ) end
  end

  context "with $www_proxy" do
    let(:params) { { :www_proxy => 'example.com' } }

    it do should contain_resource("Lxc::Www::Proxy[my-vm]").with(
      :ensure      => 'present',
      :server_name => 'example.com',
      :require     => 'Exec[lxc-start my-vm]'
    ) end
  end

  context "with $template" do
    let(:params) { { :template => 'debian' } }

    it do should contain_exec("lxc-create my-vm").with(
      :creates => '/var/lib/lxc/my-vm',
      :command => '/usr/bin/lxc-create -n my-vm -t debian -f /etc/lxc/guests/my-vm.conf',
      :require => 'File[/etc/lxc/guests/my-vm.conf]'
    ) end
  end

  context "with $vm_hostname" do
    let(:params) { { :vm_hostname => 'my-vm.example.com' } }

    it do should contain_file("/etc/lxc/guests/my-vm.conf").with(
      :content => /my\-vm\.example\.com/
    ) end
  end

  context "with $vm_mem_limit" do
    let(:params) { { :vm_mem_limit => '123456' } }

    it do should contain_file("/etc/lxc/guests/my-vm.conf").with(
      :content => /123456/
    ) end
  end

  context "with $vm_swap_limit" do
    let(:params) { { :vm_swap_limit => '123456' } }

    it do should contain_file("/etc/lxc/guests/my-vm.conf").with(
      :content => /123456/
    ) end
  end

  context "with $vm_ip" do
    let(:params) { { :vm_ip => '123456' } }

    it do should contain_file("/etc/lxc/guests/my-vm.conf").with(
      :content => /123456/
    ) end
  end

  context "with $ensure => stopped" do
    let(:params) { { :ensure => 'stopped' } }

    it do should contain_exec("lxc-shutdown my-vm").with(
      :unless  => "/usr/bin/lxc-info -n my-vm | grep state | grep STOPPED",
      :command => '/usr/bin/lxc-shutdown -n my-vm -w 60'
    ) end
  end

  context "with $ensure => absent" do
    let(:params) { { :ensure => 'absent' } }

    it do should contain_exec("lxc-shutdown my-vm").with(
      :unless  => "/usr/bin/lxc-info -n my-vm | grep state | grep STOPPED",
      :command => '/usr/bin/lxc-shutdown -n my-vm -w 60'
    ) end

    it do should contain_exec("lxc-destroy my-vm").with(
      :onlyif  => '/usr/bin/test -d /var/lib/lxc/my-vm',
      :command => '/usr/bin/lxc-destroy -n my-vm',
      :require => 'Exec[lxc-shutdown my-vm]'
    ) end

    it do should contain_file("/etc/lxc/guests/my-vm.conf").with(
      :ensure => 'absent'
    ) end

    it do should contain_file("/etc/lxc/auto/my-vm.conf").with(
      :ensure => 'absent'
    ) end

    context "with $www_proxy" do
      let(:params) { { :www_proxy => 'example.com', :ensure => 'absent' } }

      it do should contain_resource("Lxc::Www::Proxy[my-vm]").with(
        :ensure  => 'absent',
        :require => 'Exec[lxc-destroy my-vm]'
      ) end
    end
  end
end
