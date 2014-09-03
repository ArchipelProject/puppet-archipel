class archipel::central_server_nonvagrant{
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
  class { 'ejabberd':
    #TODO replace source with a template.
    config_content  => template('archipel/ejabberd.cfg.erb'),
    package_ensure  => 'installed',
    package_name    => 'ejabberd',
    service_reload  => true,
    include_epel    => false,
  }
  package { ['erlang-xmlrpc','erlang-tools','erlang-xmerl','subversion']:
    ensure => present,
    require => Package['ejabberd'],
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
  #TODO: ejabberd dropped its 32/64bit folder declaration, add later.
  file { '/usr/lib64/ejabberd/ebin/ejabberd_xmlrpc.beam':
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
    host        => $::fqdn,
    password    => 'admin',
    require     => [ File['/etc/ejabberd/ejabberd.cfg'],
                     Service['ejabberd'], ],
  }
  ->
  exec { "pip install sqlalchemy":
    unless => "ls /usr/lib/python2.6/site-packages/SQLAlchemy-*"
  }
  ->
  #buildCentralAgent requires sqlachemy
  exec { "/opt/archipel/ArchipelAgent/buildCentralAgent -d":
    creates  => '/usr/lib/python2.6/site-packages/archipel-central-agent.egg-link',
    require => [ Class["archipel"], Vcsrepo['/opt/archipel'] ],
  }
  ->
  exec { "archipel-tagnode --jid=admin@${fqdn} --password=admin --create":
    unless => "archipel-tagnode --jid=admin@${fqdn} --password=admin --list",
    require => [ Exec[ "pip install sqlalchemy"],
                 File['/etc/ejabberd/ejabberd.cfg'] ],
  }
  exec { "archipel-rolesnode --jid=admin@${fqdn} --password=admin --create":
    unless => "archipel-rolesnode --jid=admin@${fqdn} --password=admin --list",
    require => [ Exec[ "pip install sqlalchemy"],
                 File['/etc/ejabberd/ejabberd.cfg'] ],
  }
  exec { "archipel-adminaccounts --jid=admin@${fqdn} --password=admin --create":
    unless => "archipel-adminaccounts --jid=admin@${fqdn} --password=admin --list",
    require => [ Exec[ "pip install sqlalchemy"],
                 File['/etc/ejabberd/ejabberd.cfg'] ],
  }
  exec { "archipel-centralagentnode --jid=admin@${fqdn} --password=admin --create":
    # FIXME we have no idempotent way of checking that central agent node exists, so we check tagnode.
    unless => "archipel-tagnode --jid=admin@${fqdn} --password=admin --list",
    require => [ Exec[ "pip install sqlalchemy"],
               File['/etc/ejabberd/ejabberd.cfg'] ],
  }
  ->
  exec { "/opt/archipel/ArchipelAgent/archipel-central-agent/install/bin/archipel-central-agent-initinstall -x ${fqdn}":
    creates => "/etc/init.d/archipel-central-agent",
    require => Exec['/opt/archipel/ArchipelAgent/buildCentralAgent -d'],
  }
  ->
  service { "archipel-central-agent":
    ensure => "running"
  }
}
