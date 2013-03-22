#
define lxc::ssh::key (
  $key,
  $vmguest,
  $ensure   = 'present',
  $type     = 'ssh-rsa',
) {

  ssh_authorized_key { "vmguest ${name}":
    ensure  => $ensure,
    key     => $key,
    type    => $type,
    name    => "vmguest@${name}",
    user    => $vmguest,
    options => ['command="/usr/sbin/nologin"','no-pty']
  }
}
