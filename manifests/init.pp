# Installs and configures graylog collector sidecar
class graylogcollectorsidecar(
  String $api_url,
  String $version,
  Boolean $ensure = true,
  String $node_id = $facts['networking']['hostname']
) {
  if $ensure {
    $config  = present
    $package = installed
    $service = running
  } else {
    $config  = absent
    $package = absent
    $service = stopped
  }
  # Install
  exec { 'download package':
    command => "/usr/bin/wget -q https://github.com/Graylog2/collector-sidecar/releases/download/${version}/collector-sidecar_${version}-1_${facts['os']['architecture']}.deb -O /opt/collector-sidecar_${version}-1_${facts['os']['architecture']}.deb",
    creates => "/opt/collector-sidecar_${version}-1_${facts['os']['architecture']}.deb"
  }
  package { 'graylog-sidecar':
    ensure   => $package,
    name     => 'collector-sidecar',
    provider => 'dpkg',
    source   => "/opt/collector-sidecar_${version}-1_${facts['os']['architecture']}.deb",
  }
  exec { 'install sidecar service':
    creates => '/etc/systemd/system/collector-sidecar.service',
    command => 'graylog-collector-sidecar -service install',
    path    => [ '/usr/bin', '/bin' ],
  }

  # Config
  concat { '/etc/graylog/collector-sidecar/collector_sidecar.yml':
    ensure => $config,
    notify => Service['sidecar']
  }
  concat::fragment { 'main-config':
    require => Exec['install sidecar service'],
    content => template('graylogcollectorsidecar/collector_sidecar.yml.erb'),
    target  => '/etc/graylog/collector-sidecar/collector_sidecar.yml',
    order   => '01'
  }

  service { 'sidecar':
      ensure => $service,
      name   => 'collector-sidecar',
  }
}
