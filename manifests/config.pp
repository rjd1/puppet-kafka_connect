# Manages the Kafka Connect configuration.
#
# @api private
#
class kafka_connect::config {
  assert_private()

  $kafka_servers = join( $kafka_connect::bootstrap_servers, ',')

  file { 'connect-distributed':
    ensure  => 'present',
    path    => '/usr/bin/connect-distributed',
    content => template('kafka_connect/connect-distributed.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  file { '/etc/kafka/connect-distributed.properties':                                                              
    ensure  => 'present',
    content => template('kafka_connect/connect-distributed.properties.erb'),
    owner   => $owner,
    group   => $group,
    mode    => '0640',
  }
   
  file { '/etc/kafka/connect-log4j.properties':
    ensure  => 'present',
    content => template('kafka_connect/connect-log4j.properties.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

}