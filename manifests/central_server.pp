class archipel::central_server{
  include ejabberd
  ejabberd::contrib::module{ 'mod_xmlrpc': }

  ejabberd_user { 'admin':
    host        => 'archipel_central_server.archipel.priv',
    password    => 'admin'
  }
}
