# @summary Manages the Kafka Connect user and group.
#
# KC user class.
#
# @api private
#
class kafka_connect::user {
  assert_private()

  $ensure = $kafka_connect::user_and_group_ensure

  group { $kafka_connect::group :
    ensure => $ensure,
    system => true,
  }

  user { $kafka_connect::user :
    ensure  => $ensure,
    gid     => $kafka_connect::group,
    home    => '/var/empty',
    shell   => '/sbin/nologin',
    system  => true,
    require => Group[$kafka_connect::group],
  }
}
