
class lxc::params {

  # The values in this file have only been tested and used with Ubuntu.
  # Feel free to correct any of the paths (and file that PR!)

  $debootstrap_mirror = "http://archive.ubuntu.com/ubuntu"

  $vm_dir_path = $::operatingsystem ? {
    /(?i:Debian|Ubuntu|Mint)/              => '/var/lib/lxc',
    /(?i:Gentoo|RedHat|CentOS|Scientific)/ => '/var/lxc',
    /(?i:Amazon|Linux|Fedora)/             => '/var/lxc',
    default                                => '/var/lib/lxc',
  }

  $config_dir_path    = '/etc/lxc/guests'
  $autostart_dir_path = '/etc/lxc/auto'

}
