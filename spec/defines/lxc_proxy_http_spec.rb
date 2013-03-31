require 'spec_helper'

describe "lxc::proxy::http" do
  let(:title) { 'my-vm' }
  let(:params) { { :server_name => 'example.com' } }

  it { should include_class('nginx') }

  it do should contain_resource("Nginx::Site[my-vm]").with(
    :ensure  => 'present'
  ) end

  context "with $ensure => absent" do
    let(:params) { { :server_name => "example.com", :ensure => 'absent' } }
    it do should contain_resource("Nginx::Site[my-vm]").with(
      :ensure  => 'absent'
    ) end
  end

  context "nginx.conf" do
    let(:params) { { :server_name => server_name } }
    let(:content) { catalogue.resource('nginx::site','my-vm').send(:parameters)[:content] }
    subject { content }

    context "when $server_name is example.com" do
      let(:server_name) { 'example.com' }

      it { should be_include('upstream my_vm_80 ') }
      it { should be_include("proxy_pass http://my_vm_80;") }
      it { should be_include("listen 80;") }
      it { should be_include("server_name example.com;") }
    end

    context "when $server_name is example.com:80 example.com:8080" do
      let(:server_name) { 'example.com:80 example.com:8080' }

      it { should be_include('upstream my_vm_80 ') }
      it { should be_include('upstream my_vm_8080 ') }
      it { should be_include("proxy_pass http://my_vm_80;") }
      it { should be_include("proxy_pass http://my_vm_8080;") }
      it { should be_include("listen 80;") }
      it { should be_include("listen 8080;") }
      it { should be_include("server_name example.com;") }
    end

  end
end
