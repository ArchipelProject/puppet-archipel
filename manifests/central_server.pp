class archipel::central_server{
  include ejabberd
  ejabberd::contrib::module{ 'mod_xmlrpc': }
}
