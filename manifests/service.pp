# Manages the Kafka Connect service.
#
# @api private
#
class kafka_connect::service {
  assert_private()

  service { $kafka_connect::service_name :
    ensure => $kafka_connect::service_ensure,
    enable => $kafka_connect::service_enable,
  }

}
