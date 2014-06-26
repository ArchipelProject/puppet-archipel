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
  package { ["python-imaging","numpy","libvirt","libvirt-python","qemu-kvm"]:
    #gcc, python-devel, are for the native extensions of sqlalchemy installed below
    ensure => present
  }
  ->
  exec { "/vagrant/Archipel/ArchipelAgent/buildAgent -d":
    unless => "ls /usr/lib/python2.6/site-packages/archipel-*",
    require => Class["archipel"]
  }
  ->
  exec { "pip install sqlalchemy":
    unless => "ls /usr/lib/python2.6/site-packages/SQLAlchemy-*"
  }
  ->
  exec { "pip install apscheduler==2.1.2":
    unless => "ls /usr/lib/python2.6/site-packages/APScheduler-*"
  }
  ->
  exec { "archipel-initinstall -x central-server.archipel.priv":
   unless => "ls /etc/init.d/archipel"
  }
  ->
  # edit configuration
  exec { "sed -i 's/vmparking.*$/vmparking = True/' /etc/archipel/modules.d/vmparking.conf": }
  ->
  service { "libvirtd":
    ensure => "running"
  }
  ->
  # add the hyp the list of xmlrpc authorized users
  exec { "archipel-ejabberdadmin -j admin@central-server.archipel.priv -p admin -a ${fqdn}@central-server.archipel.priv":
   unless => "archipel-ejabberdadmin -j admin@central-server.archipel.priv -p admin -l | grep ${fqdn}"
  }
  ->
  service { "archipel":
    ensure => "running"
  }
}
