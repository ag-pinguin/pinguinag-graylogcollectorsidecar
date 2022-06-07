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
  case $::osfamily {
    'Debian': {
        exec { 'download package':
        command => "/usr/bin/wget -q https://github.com/Graylog2/collector-sidecar/releases/download/${version}/graylog-sidecar_${version}-1_${facts['os']['architecture']}.deb -O /opt/collector-sidecar_${version}-1_${facts['os']['architecture']}.deb",
        creates => "/opt/collector-sidecar_${version}-1_${facts['os']['architecture']}.deb"
        }
        package { 'graylog-sidecar':
          ensure   => $package,
          name     => 'collector-sidecar',
          provider => 'dpkg',
          source   => "/opt/collector-sidecar_${version}-1_${facts['os']['architecture']}.deb",
        }
        exec { 'install sidecar service':
          creates => '/etc/systemd/system/graylog-sidecar.service',
          command => 'graylog-sidecar -service install',
          path    => [ '/usr/bin', '/bin' ],
        }
        # Config
        concat { '/etc/graylog/sidecar/sidecar.yml':
            ensure => $config,
            notify => Service['sidecar']
        }
        concat::fragment { 'main-config':
            require => Exec['install sidecar service'],
            content => template('graylogcollectorsidecar/sidecar.yml.erb'),
            target  => '/etc/graylog/sidecar/sidecar.yml',
            order   => '01'
        }
        service { 'sidecar':
              ensure => $service,
              name   => 'graylog-sidecar',
         }
    }
    'RedHat': {
        exec { 'download package':
          command => "/usr/bin/wget -q https://github.com/Graylog2/collector-sidecar/releases/download/${version}/graylog-sidecar-${version}-1.${facts['os']['architecture']}.rpm -O /opt/collector-sidecar_${version}-1_${facts['os']['architecture']}.rpm",
          creates => "/opt/collector-sidecar_${version}-1_${facts['os']['architecture']}.rpm"
        }
        package { 'graylog-sidecar':
          ensure   => $package,
          name     => 'graylog-sidecar',
          provider => 'rpm',
          source   => "/opt/collector-sidecar_${version}-1_${facts['os']['architecture']}.rpm",
        }
        exec { 'install sidecar service':
          creates => '/etc/systemd/system/graylog-sidecar.service',
          command => 'graylog-sidecar -service install',
          path    => [ '/usr/bin', '/bin' ],
        }
        #Config
        concat { '/etc/graylog/sidecar/sidecar.yml':
          ensure => $config,
          notify => Service['sidecar']
        }
        concat::fragment { 'main-config':
          require => Exec['install sidecar service'],
          content => template('graylogcollectorsidecar/sidecar.yml.erb'),
          target  => '/etc/graylog/sidecar/sidecar.yml',
          order   => '01'
        }
        service { 'sidecar':
            ensure => $service,
            name   => 'graylog-sidecar',
        }
      }
  }
}
