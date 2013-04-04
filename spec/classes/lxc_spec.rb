require 'spec_helper'

describe 'lxc' do
  it { should include_class("lxc::params") }

  it { should contain_package("lxc") }
  it { should contain_package("resolvconf") }

  it do should contain_service("lxc").with(
    :ensure  => 'running',
    :enable  => true,
    :require => %w{ Package[lxc] Package[resolvconf] }
  ) end

  it do should contain_file("/etc/lxc/guests").with(
    :ensure  => 'directory',
    :require => 'Service[lxc]'
  ) end

  it do should contain_resource("File_line[lxc resolver]").with(
    :ensure  => 'present',
    :line    => 'nameserver 10.0.3.1',
    :path    => '/etc/resolvconf/resolv.conf.d/head',
    :require => %w{ Service[lxc-net] Package[resolvconf] }
  ) end

  it do should contain_exec("lxc resolvconf").with(
    :command     => '/sbin/resolvconf -u',
    :refreshonly => true,
    :subscribe   => 'File_line[lxc resolver]'
  ) end

  context "when $containers" do
    let(:default_params) { {
      "containers"  => {
        "vm0" => { "ensure" => 'present' },
        "vm1" => { "ensure" => 'present' }
      }
    } }
    let(:params) { default_params }

    %w{ vm0 vm1 }.each do |vm|
      it { should contain_resource("Lxc::Vm[#{vm}]").with_ensure("present") }
    end

    context "and $facts" do
      let(:fact) { { "name" => "value" } }
      let(:params) { default_params.merge :facts => fact }

      %w{ vm0 vm1 }.each do |vm|
        it { should contain_resource("Lxc::Vm[#{vm}]").with(:facts => fact ) }
      end

    end
  end
end
