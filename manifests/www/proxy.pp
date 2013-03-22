#
define lxc::www::proxy (
  $server_name,
  $ensure = 'present'
) {

  nginx::site { $name:
    ensure  => $ensure,
    content => template('lxc/nginx.conf.erb')
  }
}
