# @summary Class to manage individual Kafka Connect connectors.
#
# @api private
#
class kafka_connect::manage_connectors {

  assert_private()

  ensure_resource('file', $kafka_connect::connector_config_dir, {'ensure' => 'directory'})

  $connectors_data = lookup(kafka_connect::connectors, Optional[Kafka_connect::Connectors], deep, undef)

  if $connectors_data != undef {
    $connectors_data.each |$connector| {

      $connector_file_name = $connector[0]
      $connector_name      = $connector[1]['name']
      $connector_config    = $connector[1]['config']

      $connector_full_config = {
        name   => $connector_name,
        config => $connector_config
      }

      if ($kafka_connect::connectors_absent and $connector_name in $kafka_connect::connectors_absent) {
        $connector_ensure = 'absent'
      } else {
        $connector_ensure = 'present'
      }

      if ($kafka_connect::connectors_paused and $connector_name in $kafka_connect::connectors_paused) {
        $connector_state_ensure = 'PAUSED'
      } else {
        $connector_state_ensure = undef
      }

      file { "${kafka_connect::connector_config_dir}/${connector_file_name}" :
        ensure  => $connector_ensure,
        owner   => $kafka_connect::owner,
        group   => $kafka_connect::group,
        mode    => $kafka_connect::connector_config_file_mode,
        content => to_json($connector_full_config),
        before  => Manage_connector[$connector_name],
      }

      manage_connector { $connector_name :
        ensure                  => $connector_ensure,
        config_file             => "${kafka_connect::connector_config_dir}/${connector_file_name}",
        connector_state_ensure  => $connector_state_ensure,
        hostname                => $kafka_connect::hostname,
        port                    => $kafka_connect::rest_port,
        enable_delete           => $kafka_connect::enable_delete,
        restart_on_failed_state => $kafka_connect::restart_on_failed_state,
      }

    }
  }

  $secrets_data = lookup(kafka_connect::secrets, Optional[Kafka_connect::Secrets], deep, undef)

  if $secrets_data != undef {
    $secrets_data.each |$secret| {

      $secret_file_name  = $secret[0]
      $secret_ensure     = $secret[1]['ensure']
      $secret_connectors = $secret[1]['connectors']
      $secret_key        = $secret[1]['key']
      $secret_value      = $secret[1]['value']

      if $secret_ensure {
        $secret_file_ensure = $secret_ensure
      } else {
        $secret_file_ensure = 'present'
      }

      if $secret_file_ensure == 'absent' {
        $secret_content = undef
      } else {
        $secret_content = Sensitive("${secret_key}=${secret_value}\n")
      }

      file { $secret_file_name :
        ensure  => $secret_file_ensure,
        path    => "${kafka_connect::connector_config_dir}/${secret_file_name}",
        content => $secret_content,
        owner   => $kafka_connect::owner,
        group   => $kafka_connect::group,
        mode    => $kafka_connect::connector_secret_file_mode,
        notify  => Manage_connector[$secret_connectors],
      }

    }
  }

}
