#
define lxc::proxy::http (
  $server_name,
  $ensure = 'present'
) {
  include 'nginx'

  nginx::site { $name:
    ensure  => $ensure,
    content => template('lxc/nginx.conf.erb')
  }
}
