class archipel::central_server{
  class { 'ejabberd':
    config_source   => 'puppet:///modules/archipel/ejabberd.cfg',
    package_ensure  => 'installed',
    package_name    => 'ejabberd',
    service_reload  => true,
  }
  ejabberd::contrib::module{ 'mod_xmlrpc': }

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


  ejabberd_user { 'admin':
    host        => 'central-server.archipel.priv',
    password    => 'admin'
  }
  ->
  exec { "/vagrant/Archipel/ArchipelAgent/buildCentralAgent -d":
    unless => "ls /usr/lib/python2.6/site-packages/archipel-*",
    require => Class["archipel"]
  }
  ->
  exec { "easy_install sqlalchemy":
    unless => "ls /usr/lib/python2.6/site-packages/SQLAlchemy-*"
  }
  ->
  exec { "archipel-tagnode --jid=admin@${fqdn} --password=admin --create":
    unless => "archipel-tagnode --jid=admin@${fqdn} --password=admin --list",
    require => Exec[ "easy_install sqlalchemy"]
  }
  exec { "archipel-rolesnode --jid=admin@${fqdn} --password=admin --create":
    unless => "archipel-rolesnode --jid=admin@${fqdn} --password=admin --list",
    require => Exec[ "easy_install sqlalchemy"]
  }
  exec { "archipel-adminaccounts --jid=admin@${fqdn} --password=admin --create":
    unless => "archipel-adminaccounts --jid=admin@${fqdn} --password=admin --list",
    require => Exec[ "easy_install sqlalchemy"]
  }
  exec { "archipel-centralagentnode --jid=admin@${fqdn} --password=admin --create":
    # FIXME we have no idempotent way of checking that central agent node exists, so we check tagnode.
    unless => "archipel-tagnode --jid=admin@${fqdn} --password=admin --list",
    require => Exec[ "easy_install sqlalchemy"]
  }
  ->
  exec { "archipel-central-agent-initinstall -x ${fqdn}": }
  ->
  service { "archipel-central-agent":
    ensure => "running"
  }
}
