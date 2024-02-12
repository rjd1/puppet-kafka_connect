# @summary Manages the Kafka Connect service.
#
# @api private
#
class kafka_connect::service {

  assert_private()

  if ($kafka_connect::service_ensure == 'running' and $kafka_connect::package_ensure =~ /^(absent|purged)$/) {
    warning("Ignoring service_ensure 'running' value since package_ensure is set to ${kafka_connect::package_ensure}")

    $_service_ensure = 'stopped'
  } else {
    $_service_ensure = $kafka_connect::service_ensure
  }

  if ($kafka_connect::service_enable == true and $kafka_connect::package_ensure =~ /^(absent|purged)$/) {
    warning("Ignoring service_enable true value since package_ensure is set to ${kafka_connect::package_ensure}")

    $_service_enable = undef
  } else {
    $_service_enable = $kafka_connect::service_enable
  }

  service { $kafka_connect::service_name :
    ensure => $_service_ensure,
    enable => $_service_enable,
  }

}
