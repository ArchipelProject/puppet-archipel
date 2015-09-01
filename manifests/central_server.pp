class archipel::central_server
(
  $archipel_src_path="/vagrant"
)
{
  include archipel
  include ejabberd

  exec { "${archipel_src_path}/Archipel/ArchipelAgent/buildCentralAgent -d":
    unless => "/bin/ls /usr/lib/python2.7/site-packages/archipel-*",
    require => Class["archipel"]
  }

  exec { "/usr/bin/archipel-tagnode --jid=admin@${fqdn} --password=admin --create":
    unless => "/usr/bin/archipel-tagnode --jid=admin@${fqdn} --password=admin --list",
    require => [Exec["${archipel_src_path}/Archipel/ArchipelAgent/buildCentralAgent -d"], Class["ejabberd"]]
  }
  ->
  exec { "/usr/bin/archipel-rolesnode --jid=admin@${fqdn} --password=admin --create":
    unless => "/usr/bin/archipel-rolesnode --jid=admin@${fqdn} --password=admin --list",
  }
  ->
  exec { "/usr/bin/archipel-adminaccounts --jid=admin@${fqdn} --password=admin --create":
    unless => "/usr/bin/archipel-adminaccounts --jid=admin@${fqdn} --password=admin --list",
  }
  ->
  exec { "/usr/bin/archipel-centralagentnode --jid=admin@${fqdn} --password=admin --create":}
  ->
  exec { "/usr/bin/archipel-central-agent-initinstall -x ${fqdn}":
    unless => "/bin/ls /etc/init.d/archipel-central-agent"
  }
  ->
  service { "archipel-central-agent":
    ensure => "running"
  }

  package { 'httpd':
    ensure => installed,
  }

  service { 'httpd':
    enable      => true,
    ensure      => running,
    require    => Package['httpd'],
  }

exec { 'deploy_ui':
  command      => '/usr/bin/curl http://nightlies.archipelproject.org/latest-archipel-client.tar.gz | tar xz -C /var/www/html/',
  unless => "/bin/ls /var/www/html/Archipel",
  require => Package['httpd']
}

}
