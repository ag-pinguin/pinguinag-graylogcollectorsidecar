define graylogcollectorsidecar::tags(
  Array $tags,
) {
  concat::fragment { $title:
    content => template('graylogcollectorsidecar/tag.erb'),
    target  => '/etc/graylog/collector-sidecar/collector_sidecar.yml',
  }
}
