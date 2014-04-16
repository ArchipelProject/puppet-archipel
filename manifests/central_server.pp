class archipel::central_server{
  class { 'ejabberd':
    config_source   => 'puppet:///modules/archipel/ejabberd.cfg',
    package_ensure  => 'installed',
    package_name    => 'ejabberd',
    service_reload  => true,
  }
  ejabberd::contrib::module{ 'mod_xmlrpc': }

  ejabberd_user { 'admin':
    host        => 'central-server.archipel.priv',
    password    => 'admin'
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
  include archipel
  exec { "/vagrant/Archipel/ArchipelAgent/buildCentralAgent -d":
    unless => "ls /usr/lib/python2.6/site-packages/archipel-*",
    require => Class["archipel"]
  }
  ->
  exec { "archipel-tagnode --jid=admin@#{::fqdn} --password=admin --create && \
    archipel-rolesnode --jid=admin@#{::fqdn} --password=admin --create && \
    archipel-adminaccounts --jid=admin@#{::fqdn} --password=admin --create && \
    archipel-vmrequestnode --jid=admin@#{::fqdn} --password=admin --create": }
  ->
  exec { "archipel-central-agent-initinstall -x #{::fqdn}": }
}
