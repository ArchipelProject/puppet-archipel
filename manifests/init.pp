class archipel( $include_pkg_repos = true ){

  #assume git package is named 'git'
  if ! defined(Package['git']) {
    package { 'git':
      ensure => installed,
    }
  }
  if $::operatingsystem == 'centos' {

    if $include_pkg_repos == true {
      include epel
    }

    package { ["python-setuptools","gcc","python-devel",
               "python-pip"]:
    }
    ->
    exec { "/usr/bin/pip install sqlalchemy":
    unless => "/bin/ls /usr/lib/python2.7/site-packages/SQLAlchemy-*"
    }

    service { 'firewalld':
      ensure => 'stopped',
      enable => false,
    }

  }
}
