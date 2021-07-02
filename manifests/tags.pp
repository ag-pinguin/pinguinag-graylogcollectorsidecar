# technically, tags only exist up to 0.1.8. So as to not introduce breaking
# changes, we also use this type to assing configurations
# in this case, tags are not actually tags, but names of configurations
define graylogcollectorsidecar::tags(
  Array $tags,
  String $version = lookup('graylogcollectorsidecar::version')
) {
  # up to 0.1.8 the system was using tags
  if versioncmp($version, '0.1.8') <= 1:
    concat::fragment { $title:
      content => template('graylogcollectorsidecar/tag.erb'),
      target  => '/etc/graylog/collector-sidecar/collector_sidecar.yml',
    }
  } else {
    # from 1.0.0 onwards, we have to use the graylog API to assign a config to
    # the collector.

    # returns node_id if sidecar is reg
    $node_id = 
    $tags.each | $tag | {

    }
  }
}
