#
class lxc (
  $containers = [],
  $proxy_keys = [],
) {
  include 'lxc::params'
  include 'nginx'

  package{ $lxc::params::packages:
    ensure => 'present'
  }

  service { [$lxc::params::service, $lxc::params::net_service]:
    ensure  => 'running',
    enable  => true,
    require => Package[$lxc::params::packages]
  }

  file { '/etc/lxc/guests':
    ensure  => 'directory',
    require => Service[$lxc::params::service],
  }

  file_line { 'lxc resolver':
    ensure  => 'present',
    line    => "nameserver ${lxc::params::nameserver}",
    path    => '/etc/resolvconf/resolv.conf.d/head',
    require => [Service[$lxc::params::net_service],
                Package['resolvconf']]
  }

  exec{ 'lxc resolvconf':
    command     => '/sbin/resolvconf -u',
    refreshonly => true,
    subscribe   => File_line['lxc resolver']
  }

  user { $lxc::params::vmguest:
    ensure     => present,
    system     => true,
    managehome => true,
    shell      => '/bin/bash',
    home       => "/home/${lxc::params::vmguest}",
    require    => Service[$lxc::params::service]
  }

  Service[$lxc::params::service] -> Lxc::Vm <| |>
  Service[$lxc::params::service] -> Lxc::Www::Proxy <| |>
  Service[$lxc::params::service] -> Lxc::Ssh::Key <| |>

  $vm_hash = {
    vmguest    => $lxc::params::vmguest,
  }
  create_resources('lxc::vm', $containers, $vm_hash)
  create_resources('lxc::ssh::key', $proxy_keys, $vm_hash)
}
