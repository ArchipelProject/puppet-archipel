class archipel::central_server{
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
  package { ['erlang-xmlrpc','erlang-tools','erlang-xmerl','subversion']:
    ensure => installed
  }
  ->
  vcsrepo { '/usr/local/src/ejabberd-modules':
    ensure      => present,
    provider    => svn,
    source      => 'http://svn.process-one.net/ejabberd-modules/',
  }
  ->
  exec { "compile-ejabberd-xmlrpc":
    cwd         => "/usr/local/src/ejabberd-modules/ejabberd_xmlrpc/trunk/",
    command     => "/usr/local/src/ejabberd-modules/ejabberd_xmlrpc/trunk/build.sh",
    creates     => "/usr/local/src/ejabberd-modules/ejabberd_xmlrpc/trunk/ebin/mod_xmlrpc.beam",
    environment => 'HOME=/root',
    logoutput   => true,
  }
  ->
  class { 'ejabberd':
    config_source   => 'puppet:///modules/archipel/ejabberd.cfg',
    package_ensure  => 'installed',
    package_name    => 'ejabberd',
    service_reload  => true,
  }
  ->
  file { "${ejabberd::params::lib_dir}/ebin/ejabberd_xmlrpc.beam":
    ensure  => present,
    source  => "/usr/local/src/ejabberd-modules/ejabberd_xmlrpc/trunk/ebin/ejabberd_xmlrpc.beam",
  }


  # we need deprecated ejabberd_xmlrpc. When we move to ejabberd 2.0,
  # we can use mod_xmlrpc.
  # since ejabberd_xmlrpc is not in the new git repository for modules,
  # we cannot use the puppett-ejabberd module functionality.
  #ejabberd::contrib::module{ 'mod_xmlrpc':  }

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
  exec { "archipel-central-agent-initinstall -x ${fqdn}":
    unless => "ls /etc/init.d/archipel-central-agent"
  }
  ->
  # add the hyps the list of xmlrpc authorized users
  exec { "archipel-ejabberdadmin -j admin@central-server.archipel.priv -p admin -a agent-1@central-server.archipel.priv":
   unless => "archipel-ejabberdadmin -j admin@central-server.archipel.priv -p admin -l | grep agent-1"
  }
  ->
  exec { "archipel-ejabberdadmin -j admin@central-server.archipel.priv -p admin -a agent-2@central-server.archipel.priv":
   unless => "archipel-ejabberdadmin -j admin@central-server.archipel.priv -p admin -l | grep agent-2"
  }
  ->
  service { "archipel-central-agent":
    ensure => "running"
  }
}
