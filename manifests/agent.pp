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
  exec { "archipel-tagnode --jid=admin@central_server.archipel.priv --password=admin --create":
    unless => "archipel-tagnode --jid=admin@central_server.archipel.priv --password=admin --list"
  }
  exec { "archipel-rolesnode --jid=admin@central_server.archipel.priv --password=admin --create":
    unless => "archipel-tagnode --jid=admin@central_server.archipel.priv --password=admin --list"
  }
    archipel-rolesnode --jid=admin@central_server.archipel.priv --password=admin --create && \
    archipel-adminaccounts --jid=admin@central_server.archipel.priv --password=admin --create":}
  exec { "archipel-initinstall": }
}
