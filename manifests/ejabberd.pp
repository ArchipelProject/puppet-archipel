class ejabberd
(
  $ejabberd_release='16.02',
  $ejabberd_rpm_url="https://www.process-one.net/downloads/downloads-action.php?file=/ejabberd/16.02/ejabberd-16.02-0.x86_64.rpm"
)
{
  package { 'ejabberd':
    ensure => 'installed',
    source => "${ejabberd_rpm_url}",
    provider => 'rpm'
  }
  ->
  file { "ejabberd config file":
    path        => "/opt/ejabberd-${ejabberd_release}/conf/ejabberd.yml",
    content     => template('archipel/ejabberd.yml.erb'),
    owner       => ejabberd,
    mode        => 0644
  }
  ->
  file { "/usr/lib/systemd/system/ejabberd.service":
    ensure      => present,
    source      => "/opt/ejabberd-${ejabberd_release}/bin/ejabberd.service"
  }
  ->
  service { "ejabberd":
    ensure      => "running",
    enable      => "true"
  }
}
