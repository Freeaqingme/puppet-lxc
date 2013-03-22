require 'spec_helper'

describe "lxc::www::proxy" do
  let(:title) { 'my-vm' }
  let(:params) { { :server_name => 'example.com www.example.com:80 a.example.com:8080' } }

  it do should contain_resource("Nginx::Site[my-vm]").with(
    :ensure  => 'present',
    :content => /example\.com www\.example\.com/
  ) end

  context "with $ensure => absent" do
    let(:params) { { :server_name => "example.com", :ensure => 'absent' } }
    it do should contain_resource("Nginx::Site[my-vm]").with(
      :ensure  => 'absent',
    ) end
  end
end
