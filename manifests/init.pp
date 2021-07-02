# Installs and configures graylog collector sidecar
class graylogcollectorsidecar(
  String $api_url,
  String $version,
  String $node_id = $facts['networking']['hostname'],
  Optional[String] $api_token = undef
) {

  # up to 0.1.8 it was called collector-sidecar, now graylog-sidecar
  if versioncmp($version, '0.1.8') > 1:
    $service_name = 'graylog-sidecar'
    $command      = 'graylog-sidecar'
    $config_path  = '/etc/graylog/sidecar/sidecar.yml'
  else:
    $service_name = 'collector-sidecar'
    $command      = 'graylog-collector-sidecar'
    $config_path  = '/etc/graylog/collector-sidecar/collector_sidecar.yml'
  # Install
  $download_url = "https://github.com/Graylog2/collector-sidecar/releases/download/${version}/${service_name}_${version}-1_${facts['os']['architecture']}.deb"
  exec { 'download package':
    command => "/usr/bin/wget -q ${download_url} -O /opt/${service_name}_${version}-1_${facts['os']['architecture']}.deb",
    creates => "/opt/${service_name}_${version}-1_${facts['os']['architecture']}.deb"
  }
  package { 'graylog-sidecar':
    ensure   => 'installed',
    name     => $service_name,
    provider => 'dpkg',
    source   => "/opt/${service_name}_${version}-1_${facts['os']['architecture']}.deb",
  }
  exec { 'install sidecar service':
    creates => "/etc/systemd/system/${service_name}.service",
    command => "${command} -service install",
    path    => [ '/usr/bin', '/bin' ],
  }

  # Config
  concat { $config_path:
    ensure => present,
    notify => Service['sidecar']
  }
  concat::fragment { 'main-config':
    require => Exec['install sidecar service'],
    content => template("graylogcollectorsidecar/${service_name}.yml.erb"),
    target  => $config_path,
    order   => '01'
  }

  service { 'sidecar':
      ensure => running,
      name   => $service_name,
  }
}
