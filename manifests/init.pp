#
class lxc (

  $default_vm_template = 'ubuntu',
  $default_interface   = 'brLxc',
  $default_facts       = {},
  $default_template    = 'lxc/guest.conf.erb',

  $package_name        = ['lxc', 'lxc-templates'],
  $service_name        = 'lxc',
  $net_service_name    = 'lxc-net',
  $config_dir_path     = $lxc::params::config_dir_path,
  $autostart_dir_path  = $lxc::params::autostart_dir_path,
  $vm_dir_path         = $lxc::params::vm_dir_path,

) inherits lxc::params {

  package{ 'lxc':
    name   => $package_name,
    ensure => 'present'
  }

  service { 'lxc':
    name    => [$service_name, $net_service_name],
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
