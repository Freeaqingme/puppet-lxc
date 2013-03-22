require 'spec_helper'

describe "lxc::ssh::key" do
  let(:title) { 'my-vm' }
  let(:default_params) { { :vmguest => 'vmguest', :key => 'ssh key' } }
  let(:params) { default_params }

  it do should contain_resource("Ssh_authorized_key[vmguest my-vm]").with(
    :ensure  => 'present',
    :key     => 'ssh key',
    :type    => 'ssh-rsa',
    :name    => 'vmguest@my-vm',
    :user    => 'vmguest'
  ) end

  context "with $ensure => absent" do
    let(:params) { default_params.merge(:ensure => "absent") }
    it do should contain_resource("Ssh_authorized_key[vmguest my-vm]").with(
      :ensure  => 'absent'
    ) end
  end
end
