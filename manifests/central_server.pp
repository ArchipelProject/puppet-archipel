class archipel::central_server{
  class { 'ejabberd':
    config_source   => 'puppet:///modules/archipel/ejabberd.cfg',
    package_ensure  => 'installed',
    package_name    => 'ejabberd',
    service_reload  => true,
  }
  ejabberd::contrib::module{ 'mod_xmlrpc': }

  ejabberd_user { 'admin':
    host        => 'archipel_central_server.archipel.priv',
    password    => 'admin'
  }
}
