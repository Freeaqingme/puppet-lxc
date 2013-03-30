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

  Service[$lxc::params::service] -> Lxc::Vm <| |>
  Service[$lxc::params::service] -> Lxc::Www::Proxy <| |>

  create_resources('lxc::vm', $containers)
}
