#
class lxc (

  $default_vm_template     = 'ubuntu',
  $default_bridge          = 'lxcbr0',
  $default_facts           = {},
  $default_template        = 'lxc/vm.conf.erb',
  $default_mem_limit       = '256M',
  $default_total_mem_limit = '512M',
  
  $configure_bridge        = true,
  $bridge_address          = '10.0.3.1',
  $bridge_netmask          = '255.255.255.0',
  $bridge_network          = '10.0.3.0/24',
  $bridge_dhcp_range       = '10.0.3.2,10.0.3.254',
  $bridge_dhcp_max         = 253,

  $debootstrap_mirror      = $lxc::params::debootstrap_mirror,
  $package_name            = 'lxc', # [ , 'lxc-templates'],
  $service_name            = 'lxc',
  $net_service_name        = 'lxc-net',
  $config_dir_path         = $lxc::params::config_dir_path,
  $autostart_dir_path      = $lxc::params::autostart_dir_path,
  $vm_dir_path             = $lxc::params::vm_dir_path,
  
) inherits lxc::params {

  # Todo Validation

  package{ 'lxc':
    name    => "${package_name}",
    ensure  => 'present',
  }

  file { 'lxc-defaults':
    path    => '/etc/default/lxc', # Todo: Make configurable
    owner   => root,
    group   => root,
    mode    => 0640,
    content => template('lxc/defaults.erb'),
    require => Package[ 'lxc' ],
    notify  => Service[ 'lxc' ],
  }

  service { 'lxc':
    name    => $service_name,
    ensure  => 'running',
    enable  => true,
    require => Package['lxc']
  }

  service { 'lxc-net':
    name    => $net_service_name,
    ensure  => 'running',
    enable  => true,
    require => Package['lxc']
  }

  file { 'lxc-config-dir':
    path    => $config_dir_path,
    ensure  => 'directory',
    require => Service['lxc'],
  }

  Service[$service_name] -> Lxc::Vm <| |>

}
