#
class lxc::params (
  $packages    = ['lxc', 'resolvconf'],
  $service     = 'lxc',
  $net_service = 'lxc-net',
  $nameserver  = '10.0.3.1',
  $vmguest     = 'vmguest',
) {
}
