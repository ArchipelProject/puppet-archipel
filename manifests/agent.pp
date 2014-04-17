class archipel::agent{
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
  include archipel
  exec { "/vagrant/Archipel/ArchipelAgent/buildAgent -d":
    unless => "ls /usr/lib/python2.6/site-packages/archipel-*",
    require => Class["archipel"]
  }
  ->
  package { ["python-imaging","python-setuptools","gcc","python-devel","numpy"]:
    #gcc, python-devel, are for the native extensions of sqlalchemy installed below
    ensure => present
  }
  ->
  exec { "easy_install sqlalchemy":
    unless => "ls /usr/lib/python2.6/site-packages/SQLAlchemy-*"
  }
  ->
  exec { "easy_install APScheduled":
    unless => "ls /usr/lib/python2.6/site-packages/APScheduler-*"
  }
  ->
  exec { "archipel-initinstall": }
}
