# @summary Class to manage individual Kafka Connect connectors.
#
# @param connectors_data
#   Hash of connector names and their corresponding data.
#
# @api private
#
class kafka_connect::manage_connectors::connector (
  Kafka_connect::Connectors $connectors_data,
) {
  assert_private()

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

    if ($connector_ensure == 'present' and !$connector_config) {
      fail("Connector config required, unless ensure is set to absent. \
        \n Validation error on ${connector_name} data, please correct. \n")
    }

    if $kafka_connect::owner {
      $_owner = $kafka_connect::owner
    } else {
      $_owner = $kafka_connect::user
    }

    file { "${kafka_connect::connector_config_dir}/${connector_file_name}" :
      ensure  => $connector_ensure,
      owner   => $_owner,
      group   => $kafka_connect::group,
      mode    => $kafka_connect::connector_config_file_mode,
      content => stdlib::to_json($connector_full_config),
      before  => Kc_connector[$connector_name],
    }

    kc_connector { $connector_name :
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
