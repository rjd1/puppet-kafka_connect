# @summary Manage KC connectors
#
# Private class to manage individual kafka-connect connectors.
#
# @param connectors_absent
#   List of connectors to ensure absent.
# @param connectors_paused
#   List of connectors to ensure paused.
# @param connector_config_dir
#   Configuration directory for connector properties files.
# @param owner
#   Owner to set on connector and secret file permissions.
# @param group
#   Group to set on connector and secret file permissions.
# @param hostname
#   The hostname or IP of the KC service.
# @param rest_port
#   Port to connect to for the REST API.
# @param enable_delete
#   Enable delete of running connectors.
#   Required for the provider to actually remove when set to absent.
# @param restart_on_failed_state
#   Allow the provider to auto restart on FAILED connector state.
#
# @author https://github.com/rjd1/puppet-kafka_connect/graphs/contributors
#
# @api private
#
class kafka_connect::manage_connectors (
  Optional[Array] $connectors_absent       = $::kafka_connect::connectors_absent,
  Optional[Array] $connectors_paused       = $::kafka_connect::connectors_paused,
  String          $config_dir              = $::kafka_connect::connector_config_dir,
  String          $owner                   = $::kafka_connect::owner,
  String          $group                   = $::kafka_connect::group,
  String          $hostname                = $::kafka_connect::hostname,
  Integer         $rest_port               = $::kafka_connect::rest_port,
  Boolean         $enable_delete           = $::kafka_connect::enable_delete,
  Boolean         $restart_on_failed_state = $::kafka_connect::restart_on_failed_state,
) {

  assert_private()

  ensure_resource('file', $config_dir, {'ensure' => 'directory'})

  $connectors_data = lookup(kafka_connect::connectors, Optional[Hash[String[1],Any]], deep, undef)

  if $connectors_data != undef {
    $connectors_data.each |$connector| {

      $connector_file_name = $connector[0]
      $connector_name      = $connector[1]['name']
      $connector_config    = $connector[1]['config']

      $connector_full_config = {
        name   => $connector_name,
        config => $connector_config
      }

      if ($connectors_absent and $connector_name in $connectors_absent) {
        $connector_ensure = 'absent'
      } else {
        $connector_ensure = 'present'
      }

      if ($connectors_paused and $connector_name in $connectors_paused) {
        $conn_state_ensure = 'PAUSED'
      } else {
        $conn_state_ensure = undef
      }

      file { "${config_dir}/${connector_file_name}" :
        ensure  => $connector_ensure,
        owner   => $owner,
        group   => $group,
        mode    => '0640',
        content => to_json($connector_full_config),
        before  => Manage_connector[$connector_name],
      }

      manage_connector { $connector_name :
        ensure                  => $connector_ensure,
        config_file             => "${config_dir}/${connector_file_name}",
        connector_state_ensure  => $conn_state_ensure,
        hostname                => $hostname,
        port                    => $rest_port,
        enable_delete           => $enable_delete,
        restart_on_failed_state => $restart_on_failed_state,
      }

    }
  }

  $secrets_data = lookup(kafka_connect::secrets, Optional[Hash[String[1],Any]], deep, undef)

  if $secrets_data != undef {
    $secrets_data.each |$secret| {

      $secret_file_name  = $secret[0]
      $secret_connectors = $secret[1]['connectors']
      $secret_key        = $secret[1]['key']
      $secret_value      = $secret[1]['value']

      $secret_content = Sensitive("${secret_key}=${secret_value}\n")

      file { $secret_file_name :
        ensure  => 'present',
        path    => "${config_dir}/${secret_file_name}",
        content => $secret_content,
        owner   => $owner,
        group   => $group,
        mode    => '0600',
        notify  => Manage_connector[$secret_connectors],
      }

    }
  }

}
