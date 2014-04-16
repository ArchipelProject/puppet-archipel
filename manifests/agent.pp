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
  exec { "archipel-tagnode --jid=admin@${fqdn} --password=admin --create && \
    archipel-rolesnode --jid=admin@${fqdn} --password=admin --create && \
    archipel-adminaccounts --jid=admin@${fqdn} --password=admin --create":}
  ->
  exec { "archipel-initinstall": }
}
