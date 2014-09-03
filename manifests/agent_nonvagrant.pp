requires 
# - vcsrepo
# - ejabberd 


class archipel::agent_nonvagrant{
  include archipel
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
  vcsrepo { '/opt/archipel':
   ensure   => present,
   provider => git,
   source   => 'https://github.com/ArchipelProject/Archipel.git',
  }
  package { ["python-imaging","numpy","libvirt","libvirt-python","qemu-kvm"]:
    #gcc, python-devel, are for the native extensions of sqlalchemy installed below
    ensure => present
  }
  ->
  exec { "/opt/archipel/ArchipelAgent/buildAgent -d":
    unless => "ls /usr/lib/python2.6/site-packages/archipel-*",
    require => [ Vcsrepo['/opt/archipel'] ],
  }
  ->
  exec { "pip install apscheduler==2.1.2":
    unless => "ls /usr/lib/python2.6/site-packages/APScheduler-*"
  }
  ->
  exec { "/usr/bin/archipel-initinstall -x ${::fqdn}":
   unless  => "ls /etc/init.d/archipel",
   require => Exec['/opt/archipel/ArchipelAgent/buildCentralAgent -d'],
  }
  ->
  # edit configuration
  exec { "sed -i 's/vmparking.*$/vmparking = True/' /etc/archipel/modules.d/vmparking.conf": }
  ->
  service { "libvirtd":
    ensure  => 'running',
    require => Package['libvirt'],
  }
  ->
  # add the hyp the list of xmlrpc authorized users
  exec { "archipel-ejabberdadmin -j admin@${::fqdn} -p admin -a ${fqdn}@central-server.archipel.priv":
   unless => "archipel-ejabberdadmin -j admin@${::fqdn} -p admin -l | grep ${fqdn}"
  }
  ->
  service { "archipel":
    ensure => "running"
  }
}
