#
# Parameters
#
# [*hostname*]
#   Optional. Derived from $name
#
# [*ip_v4*]
#   IPv4 address to provision vm with (optional)
#
# [*ip_v6*]
#   IPv6 address to provision vm with (optional)
#   
# [*ensure*]
#
# [*enable*]
#
# [*comment*]
#
# [*mem_limit*]
#   Ram limit. E.g. '512M'
#
# [*total_mem_limit*]
#   Ram + Swap limit. E.g. '1024M'
#
# [*template*]
#
# [*vm_template*]
#
# [*interface*]
#   The networking interface (bridge) to connect the primary link to
#
# [*facts*]
#
#
define lxc::vm (
  $hostname        = $name,
  $ip_v4           = '',
  $ip_v6           = '',
  $ensure          = 'present',
  $enable          = true,
  $comment         = 'Managed by Puppet',

  $mem_limit       = $lxc::default_mem_limit,
  $total_mem_limit = $lxc::default_total_mem_limit,
  $template        = $lxc::default_template,
  $vm_template     = $lxc::default_vm_template,
  $interface       = $lxc::default_interface,
  $facts           = $lxc::default_facts
) {

  include lxc

  validate_string($hostname)
  if $ip_v4 != '' { validate_ipv4_address($ip_v4) }
  if $ip_v6 != '' { validate_ipv6_address($ip_v6) }
  validate_re($ensure, ['present','absent' ], 'Valid values: present, absent')
  validate_bool($enable)
  if $comment != '' { validate_string($comment) }
  validate_string($mem_limit)
  validate_string($total_mem_limit)
  validate_string($template)  
  validate_string($vm_template)
  validate_string($interface)

  $config_file  = "${lxc::config_dir_path}/${name}.conf"

  case $ensure {
    'present': {

      file { "lxc-vm-${name}-conf":
        path    => $config_file,
        ensure  => 'present',
        content => template('lxc/guest.conf.erb'),
        require => File['lxc-config-dir']
      }

      exec { "lxc-vm-${name}-create":
        creates   => "${lxc::vm_dir_path}/${name}",
        command   => "lxc-create -n ${name} -t ${vm_template} -f ${config_file}",
        logoutput => 'on_failure',
        timeout   => 30000,
        require   => File[ "lxc-vm-${name}-conf" ]
      }

      case $enable {
        true: {
          file { "lxc-vm-${name}-autostart-symlink":
            path    => "${lxc::autostart_dir_path}/${name}.conf",
            ensure  => 'link',
            target  => "${lxc::vm_dir_path}/${name}/config",
            require => Exec["lxc-vm-${name}-create"]
          }

          exec { "lxc-vm-${name}-start":
            unless    => "lxc-info -n ${name} | grep state | grep RUNNING",
            command   => "lxc-start -n ${name} -d",
            logoutput => 'on_failure',
            require   => Exec["lxc-vm-${name}-create"]
          }
        }
        false: {
          file { "lxc-vm-${name}-autostart-symlink":
            path    => "${lxc::autostart_dir_path}/${name}.conf",
            ensure  => 'absent',
          }

          exec { "lxc-vm-${name}-stop":
            unless    => "lxc-info -n ${name} | grep state | grep STOPPED",
            command   => "lxc-shutdown -n ${name} -w 60",
            logoutput => 'on_failure',
            require   => Exec["lxc-vm-${name}-create"]
          }
        }
      }

      if '0' != inline_template('<%=@facts.length %>') {
        file { [ "${lxc::vm_dir_path}/${name}/rootfs/etc/facter",
                 "${lxc::vm_dir_path}/${name}/rootfs/etc/facter/facts.d" ]:
            ensure => 'directory',
            require => Exc["lxc-vm-${name}-create"]
        }

        file { "${lxc::vm_dir_path}/${name}/rootfs/etc/facter/facts.d/lxc_module.yaml":
          ensure  => 'present',
          content => inline_template('<%= facts.to_yaml %>'),
          require => File["${lxc::vm_dir_path}/${name}/rootfs/etc/facter/facts.d"]
        }
      }
    }

    'absent': {
      exec { "lxc-vm-${name}-stop":
        unless  => "lxc-info -n ${name} | grep state | grep STOPPED",
        command => "lxc-shutdown -n ${name} -w"
      }
      
      exec { "lxc-vm-${name}-destroy":
        onlyif  => "/usr/bin/test -d ${lxc::vm_dir_path}/${name}",
        command => "lxc-destroy -n ${name}",
        require => Exec["lxc-vm-${name}-stop"]
      }

      file { $config_file:
        ensure => 'absent'
      }

      file { "lxc-vm-${name}-autostart-symlink":
        path    => "${lxc::autostart_dir_path}/${name}.conf",
        ensure  => 'absent',
      }

    }
  }

}
