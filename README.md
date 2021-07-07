# graylogcollectorsidecar

## Module description

Graylog Collector Sidecar is a centrally managed logging agent for graylog.

This module does not have any major dependencies (only concat) and realizes tags as resources, so you can add tags for the same node from multiple different manifests.

Note: only compatible with the old collector-sidecar (up to version 0.1.8), not the new graylog-collector. The new collector does not use tags and instead requires API actions to assign nodes to configurations. There is no way to do this on a per-node basis without race conditions, so it will not be supported.

It is only tested on Debian 9/10 and Ubuntu 16.04 / 18.04 with Puppet 5. Since it uses only build in puppet resources it should run on a wide variety of systems, but we cannot guarantee it. If you sucessfully test it on a different configuration, please let us know and we will update the metadata.

Since it uses $facts['fact'] syntax, it is not compatible with puppet 3.


## Usage

### Installation

#### Using Hiera

``` puppet
include graylogcollectorsidecar
```

Hiera:

``` yaml
graylogcollectorsidecar::api_url: 'http://my-graylog-server.example.com:9000/api'
graylogcollectorsidecar::version: '0.1.6'
```

#### Using class

``` puppet
class { 'graylogcollectorsidecar':
    api_url => 'http://my-graylog-server.example.com:9000/api',
    version => '0.1.6',
    node_id => $facts['networking']['hostname'] # this is the default
}
```

### Adding Tags

Tags are implemented as resources. This way, you can add tags over mutliple manifests, like for example profiles.

``` puppet
class { 'profiles::webserver':
  graylogcollectorsidecar::tags { 'apache':
    tags => [
      'apache.access',
      'apache.error'
    ]
  }
}

class { 'profiles::mysql':
  graylogcollectorsidecar::tags { 'mysql':
    tags => [
      'mysql.error',
      'mysql.slowquery'
    ]
  }
}
```

### Uninstall

``` puppet
class { 'graylogcollectorsidecar':
    ensure  => false,
    api_url => 'http://my-graylog-server.example.com:9000/api',
    version => '0.1.6',
    node_id => $facts['networking']['hostname'] # this is the default
}
```