# @summary Class to manage individual Kafka Connect connectors.
#
# @api private
#
class kafka_connect::manage_connectors {
  assert_private()

  ensure_resource('file', $kafka_connect::connector_config_dir, { 'ensure' => 'directory' })

  $connectors_data = lookup(kafka_connect::connectors, Optional[Kafka_connect::Connectors], deep, undef)

  if $connectors_data != undef {
    $connectors_data.each |$connector| {
      $connector_file_name = $connector[0]
      $connector_name      = $connector[1]['name']
      $connector_config    = $connector[1]['config']

      $connector_full_config = {
        name   => $connector_name,
        config => $connector_config,
      }

      $connector_ensure = $connector[1]['ensure'] ? {
        /^(present|running|paused)$/ => 'present',
        'absent'                     => 'absent',
        default                      => 'present',
      }

      $connector_state_ensure = $connector[1]['ensure'] ? {
        /^(present|running)$/ => 'RUNNING',
        'paused'              => 'PAUSED',
        'absent'              => undef,
        default               => undef,
      }

      if ($kafka_connect::connectors_absent and $connector_name in $kafka_connect::connectors_absent) {
        deprecation('kafka_connect::connectors_absent',
        'Removing through $connectors_absent is deprecated, please use the \'ensure\' hash key in the connector data instead.')

        $legacy_connector_ensure = 'absent'
      }

      if ($kafka_connect::connectors_paused and $connector_name in $kafka_connect::connectors_paused) {
        deprecation('kafka_connect::connectors_paused',
        'Pausing through $connectors_paused is deprecated, please use the \'ensure\' hash key in the connector data instead.')

        $legacy_connector_state_ensure = 'PAUSED'
      }

      if defined('$legacy_connector_ensure') {
        $_connector_ensure = $legacy_connector_ensure
      } else {
        $_connector_ensure = $connector_ensure
      }

      if defined('$legacy_connector_state_ensure') {
        $_connector_state_ensure = $legacy_connector_state_ensure
      } else {
        $_connector_state_ensure = $connector_state_ensure
      }

      if ($_connector_ensure == 'present' and !$connector_config) {
        fail("Connector config required, unless ensure is set to absent. \
          \n Validation error on ${connector_name} data, please correct. \n")
      }

      file { "${kafka_connect::connector_config_dir}/${connector_file_name}" :
        ensure  => $_connector_ensure,
        owner   => $kafka_connect::owner,
        group   => $kafka_connect::group,
        mode    => $kafka_connect::connector_config_file_mode,
        content => to_json($connector_full_config),
        before  => Kc_connector[$connector_name],
      }

      kc_connector { $connector_name :
        ensure                  => $_connector_ensure,
        config_file             => "${kafka_connect::connector_config_dir}/${connector_file_name}",
        connector_state_ensure  => $_connector_state_ensure,
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
      $secret_kv_data    = $secret[1]['kv_data']

      if $secret_ensure {
        $secret_file_ensure = $secret_ensure
      } else {
        $secret_file_ensure = 'present'
      }

      if $secret_file_ensure == 'absent' {
        $secret_content = undef
        $secret_notify  = undef
      } elsif !$secret_connectors {
        $secret_notify  = undef
      } else {
        $secret_notify  = Kc_connector[$secret_connectors]
      }

      if $secret_file_ensure =~ /^(present|file)$/ {
        unless (($secret_key and $secret_value) or $secret_kv_data) and !(($secret_key or $secret_value) and $secret_kv_data) {
          fail("Either secret key and value or kv_data is required, unless ensure is set to absent. \
            \n Validation error on ${secret_file_name} data, please correct. \n")
        }

        if $secret_kv_data {
          $secret_data    = join($secret_kv_data.map |$key,$value| { "${key}=${value}" }, "\n")
          $secret_content = Sensitive("${secret_data}\n")
        } else {
          $secret_content = Sensitive("${secret_key}=${secret_value}\n")
        }
      }

      file { $secret_file_name :
        ensure  => $secret_file_ensure,
        path    => "${kafka_connect::connector_config_dir}/${secret_file_name}",
        content => $secret_content,
        owner   => $kafka_connect::owner,
        group   => $kafka_connect::group,
        mode    => $kafka_connect::connector_secret_file_mode,
        notify  => $secret_notify,
      }
    }
  }
}
