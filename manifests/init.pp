class archipel{
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
  package { ["python-xmpp","numpy", "python-setuptools", "gcc", "python-devel"]:
    #gcc, python-devel, are for the native extensions of sqlalchemy installed below
    ensure => installed
  }
  ->
  exec { "easy_install sqlalchemy":
    unless => "ls /usr/lib/python2.6/site-packages/SQLAlchemy-*"
  }
}
