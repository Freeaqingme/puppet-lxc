#
define lxc::vm(
  $vm_mem_limit  = '512M',
  $vm_mem_plus_swap_limit = '1024M',
  $vm_hostname   = $name,
  $vm_ip         = '0.0.0.0',
  $template      = 'ubuntu',
  $ensure        = 'present',
  $enable        = true,
  $comment       = $name,
  $http_proxy    = undef
) {
  $lxc_auto     = "/etc/lxc/auto/${name}.conf"
  $config_file  = "/etc/lxc/guests/${name}.conf"

  $lxc_create   = "/usr/bin/lxc-create -n ${name}"
  $lxc_stop     = "/usr/bin/lxc-stop -n ${name}"
  $lxc_start    = "/usr/bin/lxc-start -n ${name} -d"
  $lxc_destroy  = "/usr/bin/lxc-destroy -n ${name}"
  $lxc_info     = "/usr/bin/lxc-info -n ${name}"
  $lxc_shutdown = "/usr/bin/lxc-shutdown -n ${name} -w 60"

  case $ensure {
    'present': {

      file { $config_file:
        ensure  => 'present',
        content => template('lxc/guest.conf.erb'),
        require => File['/etc/lxc/guests']
      }

      exec { "lxc-create ${name}":
        creates   => "/var/lib/lxc/${name}",
        command   => "${lxc_create} -t ${template} -f ${config_file}",
        logoutput => 'on_failure',
        require   => File[$config_file]
      }

      exec { "lxc-start ${name}":
        unless    => "${lxc_info} | grep state | grep RUNNING",
        command   => $lxc_start,
        logoutput => 'on_failure',
        require   => Exec["lxc-create ${name}"]
      }

      if $http_proxy != undef {
        lxc::proxy::http { $name:
          ensure      => 'present',
          server_name => $http_proxy,
          require     => Exec["lxc-start ${name}"]
        }
      }

      case $enable {
        true: {
          file { $lxc_auto:
            ensure  => 'link',
            target  => "/var/lib/lxc/${name}/config",
            require => Exec["lxc-create ${name}"]
          }
        }
        false: {
          file { $lxc_auto:
            ensure  => 'absent',
          }
        }
        default: {
          fail('enable must be true or false')
        }
      }
    }

    'stopped': {
      exec { "lxc-shutdown ${name}":
        unless  => "${lxc_info} | grep state | grep STOPPED",
        command => $lxc_shutdown
      }
    }

    'absent': {
      exec { "lxc-shutdown ${name}":
        unless  => "${lxc_info} | grep state | grep STOPPED",
        command => $lxc_shutdown
      }

      exec { "lxc-destroy ${name}":
        onlyif  => "/usr/bin/test -d /var/lib/lxc/${name}",
        command => $lxc_destroy,
        require => Exec["lxc-shutdown ${name}"]
      }

      if $http_proxy != undef {
        lxc::proxy::http { $name:
          ensure      => 'absent',
          server_name => $http_proxy,
          require     => Exec["lxc-destroy ${name}"]
        }
      }

      file { $config_file:
        ensure => 'absent'
      }

      file { $lxc_auto:
        ensure => 'absent'
      }
    }

    default: {
      fail('ensure must be present, absent or stopped')
    }
  }

}
