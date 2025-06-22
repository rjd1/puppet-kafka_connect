# @summary Manages individual Kafka Connect connectors.
#
# KC connector class.
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

  $stdlib_version = load_module_metadata('stdlib')['version']

  $connectors_data.each |$connector| {
    $connector_file_name = $connector[0]
    $connector_name      = $connector[1]['name']
    $connector_config    = $connector[1]['config']

    $connector_full_config = {
      name   => $connector_name,
      config => $connector_config,
    }

    $connector_full_config_content = if versioncmp($stdlib_version, '9.0.0') < 0 {
      to_json($connector_full_config)
    } else {
      stdlib::to_json($connector_full_config)
    }

    $connector_ensure = $connector[1]['ensure'] ? {
      /^(present|running|paused|stopped)$/ => 'present',
      'absent'                             => 'absent',
      default                              => 'present',
    }

    $connector_state_ensure = $connector[1]['ensure'] ? {
      /^(present|running)$/ => 'RUNNING',
      'paused'              => 'PAUSED',
      'stopped'             => 'STOPPED',
      'absent'              => undef,
      default               => undef,
    }

    if ($connector_state_ensure == 'RUNNING' or $connector_state_ensure == undef)
    and ($connector_ensure != 'absent')
    and !$connector_config {
      fail("Connector config required, unless ensure is set to absent/paused/stopped. \
        \n Validation error on ${connector_name} data, please correct. \n")
    }

    if ($connector_state_ensure == 'STOPPED')
    and ($kafka_connect::install_source == 'package')
    and (versioncmp($kafka_connect::package_ensure, '7.5.0') < 0) {
      warning("It appears you are running Confluent Platform < v7.5.0 (${kafka_connect::package_ensure}) \
        \n and trying to stop a connector - this will probably fail!")
    }

    unless ($connector_config == undef) {
      $final_config_content = $connector_full_config_content
    } else {
      $final_config_content = undef
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
      content => $final_config_content,
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
