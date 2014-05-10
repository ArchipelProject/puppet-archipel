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
  exec { "easy_install sqlalchemy":
    unless => "ls /usr/lib/python2.6/site-packages/SQLAlchemy-*"
  }
  ->
  exec { "easy_install APScheduler":
    unless => "ls /usr/lib/python2.6/site-packages/APScheduler-*"
  }
  ->
  exec { "archipel-initinstall -x central-server.archipel.priv":
   unless => "ls /etc/init.d/archipel"
  }
  ->
  # add to the list of xmlrpc authorized users
  exec { "archipel-ejabberdadmin admin@central-server.archipel.priv -p admin -a ${hostname}@central-server.archipel.priv":
   unless => "archipel-ejabberdadmin -j admin@central-server.archipel.priv -p admin -l | grep ${hostname}"
  }
  ->
  # edit configuration
  exec { "sed -i 's/use_xmlrpc_api.*$/use_xmlrpc_api=True/' /etc/archipel/archipel.conf &&\
    sed -i 's/auto_group *=.*$/auto_group = True/' /etc/archipel/archipel.conf && \
    sed -i 's/centraldb.*$/centraldb = True/' /etc/archipel/archipel.conf && \
    sed -i 's/vmparking.*$/vmparking = True/' /etc/archipel/archipel.conf":}
  ->
  service { "libvirtd":
    ensure => "running"
  }
  ->
  service { "archipel":
    ensure => "running"
  }
}
