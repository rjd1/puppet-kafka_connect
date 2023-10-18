# @summary Manages kafka-connect
#
# Main kafka_connect class
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
# @example
#   include kafka_connect
#
# @example
#   class { 'kafka_connect':
#     connector_config_dir => '/etc/kafka-connect-jdbc',
#     rest_port            => 8084,
#     enable_delete        => true,
#   }
#
# @author https://github.com/rjd1/puppet-kafka_connect/graphs/contributors
#
class kafka_connect (
  Optional[Array] $connectors_absent       = undef,
  Optional[Array] $connectors_paused       = undef,
  String          $connector_config_dir    = '/etc/kafka-connect',
  String          $owner                   = 'cp-kafka-connect',
  String          $group                   = 'confluent',
  String          $hostname                = 'localhost',
  Integer         $rest_port               = 8083,
  Boolean         $enable_delete           = false,
  Boolean         $restart_on_failed_state = false,
){

  include 'kafka_connect::manage_connectors'

}
