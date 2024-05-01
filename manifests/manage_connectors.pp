# @summary Class to manage individual Kafka Connect connectors and connector secrets.
#
# @api private
#
class kafka_connect::manage_connectors {
  assert_private()

  ensure_resource('file', $kafka_connect::connector_config_dir, { 'ensure' => 'directory' })

  $connectors_data = lookup(kafka_connect::connectors, Optional[Kafka_connect::Connectors], deep, undef)

  if $connectors_data != undef {
    class { 'kafka_connect::manage_connectors::connector':
      connectors_data => $connectors_data,
    }
  }

  $secrets_data = lookup(kafka_connect::secrets, Optional[Kafka_connect::Secrets], deep, undef)

  if $secrets_data != undef {
    class { 'kafka_connect::manage_connectors::secret':
      secrets_data => $secrets_data,
    }
  }
}
