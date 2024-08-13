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

  if $kafka_connect::run_local_kafka_broker_and_zk {
    if $kafka_connect::service_name =~ /^confluent-.*$/ {
      $service_prefix = 'confluent-'
    } else {
      $service_prefix = ''
    }

    service { ["${service_prefix}zookeeper", "${service_prefix}kafka"]:
      ensure   => $_service_ensure,
      enable   => $_service_enable,
      provider => $kafka_connect::service_provider,
      before   => Service[$kafka_connect::service_name],
    }
  }

  service { $kafka_connect::service_name :
    ensure   => $_service_ensure,
    enable   => $_service_enable,
    provider => $kafka_connect::service_provider,
  }

  exec { 'wait_30s_for_service_start':
    command     => 'sleep 30',
    refreshonly => true,
    path        => ['/bin','/usr/bin','/usr/local/bin'],
    subscribe   => Service[$kafka_connect::service_name],
  }
}
