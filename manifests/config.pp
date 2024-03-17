# @summary Manages the Kafka Connect configuration.
#
# @api private
#
class kafka_connect::config {
  assert_private()

  $kafka_servers = join( $kafka_connect::bootstrap_servers, ',')

  $file_ensure = $kafka_connect::package_ensure ? {
    /^(absent|purged)$/ => 'absent',
    default             => 'present',
  }

  file { '/usr/bin/connect-distributed':
    ensure  => $file_ensure,
    content => template('kafka_connect/connect-distributed.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  file { "${kafka_connect::kc_config_dir}/connect-distributed.properties":
    ensure  => $file_ensure,
    content => template('kafka_connect/connect-distributed.properties.erb'),
    owner   => $kafka_connect::owner,
    group   => $kafka_connect::group,
    mode    => '0640',
  }

  file { "${kafka_connect::kc_config_dir}/connect-log4j.properties":
    ensure  => $file_ensure,
    content => template('kafka_connect/connect-log4j.properties.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }
}
