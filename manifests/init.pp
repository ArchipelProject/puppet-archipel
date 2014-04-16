class archipel{
  package { ["python-xmpp","python-sqlalchemy", "numpy", "python-setuptools"]:
    ensure => installed
  }
}
