class archipel::agent
(
  $archipel_src_path="/vagrant"
)
{

  include archipel

  package { ["python-pillow","numpy","libvirt","libvirt-python","qemu-kvm"]:
    ensure => present
  }
  ->
  exec { "${archipel_src_path}/Archipel/ArchipelAgent/buildAgent -d":
    unless => "/bin/ls /usr/lib/python2.7/site-packages/archipel-*",
    require => Class["archipel"]
  }
  ->
  exec { "/usr/bin/pip install apscheduler==2.1.2":
    unless => "/bin/ls /usr/lib/python2.7/site-packages/APScheduler-*"
  }
  ->
  exec { "/usr/bin/archipel-initinstall -x central-server.archipel.priv":
   unless => "/bin/ls /etc/init.d/archipel"
  }
  ->
  # edit configuration
  exec { "/usr/bin/sed -i 's/vmparking.*$/vmparking = True/' /etc/archipel/modules.d/vmparking.conf": }
  ->
  service { "libvirtd":
    ensure => "running"
  }
  ->
  # add the hyp the list of xmlrpc authorized users
  exec { "/usr/bin/archipel-ejabberdadmin -j admin@central-server.archipel.priv -p admin -a ${fqdn}@central-server.archipel.priv":
   unless => "/usr/bin/archipel-ejabberdadmin -j admin@central-server.archipel.priv -p admin -l | grep ${fqdn}"
  }
  ->
  service { "archipel-agent":
    ensure => "running"
  }
}
