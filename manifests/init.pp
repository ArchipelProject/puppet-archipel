class archipel( $include_pkg_repos = true ){
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
  #assume git package is named 'git'
  if ! defined(Package['git']) {
    package { 'git':
      ensure => installed,
    }
  }
  exec { "pip install git+git://github.com/normanr/xmpppy.git":
    require => Package["git"]
  }
  if $::operatingsystem == 'centos' {
    if $include_pkg_repos == true {
      include epel
    }
    package { ["python-setuptools","gcc","python-devel",
               "python-argparse", "python-pip"]:
    }
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
