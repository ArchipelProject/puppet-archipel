class archipel( $include_epel = true ){
  if $include_epel == true {
    include epel
  }
  Exec {
  path => [
    '/usr/local/bin',
    '/opt/local/bin',
    '/usr/bin',
    '/usr/sbin',
    '/bin',
    '/sbin'],
  logoutput => true,
  }
  #commented out because defaults has gcc
  #package { ["python-setuptools","gcc","python-devel", "python-argparse", "python-pip"]:
  package { ["python-setuptools", "python-devel", "python-argparse", "python-pip"]:
    ensure => installed
  }

  if ! defined(Package['git']) {
    package { 'git':
      ensure => installed,
    }
  }
  exec { "pip install git+git://github.com/normanr/xmpppy.git":
    require => Package["git"]
  }
  if $::operatingsystem == 'centos' {
    service { 'iptables':
      ensure => 'stopped',
      enable => false,
    }
    service { 'ip6tables':
      ensure => 'stopped',
      enable => false,
    }
  }
}
