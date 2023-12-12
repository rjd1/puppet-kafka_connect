# Main kafka_connect class.
#
# TO-DO: add remaining params to Strings here...
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
  Boolean $manage_connectors_only = false,
  Boolean $manage_confluent_repo  = true,
  Boolean $include_java           = false,

  # kafka_connect::confluent_repo
  Enum['present', 'absent'] $repo_ensure  = 'present',
  Boolean                   $repo_enabled = true,
  String                    $repo_version = '7.1',

  # kafka_connect::install
  String          $package_name                      = 'confluent-kafka',
  String          $package_ensure                    = '7.1.1-1',
  Boolean         $manage_schema_registry_package    = true,
  String          $schema_registry_package_name      = 'confluent-schema-registry',
  String          $confluent_hub_plugin_path         = '/usr/share/confluent-hub-components',
  Array[String]   $confluent_hub_plugins             = [],
  String          $confluent_hub_client_package_name = 'confluent-hub-client',
  String          $confluent_common_package_name     = 'confluent-common',

  # kafka_connect::config
  String           $kafka_heap_options                  = '-Xms256M -Xmx2G',
  String           $config_storage_replication_factor   = '1',
  String           $config_storage_topic                = 'connect-configs',
  String           $group_id                            = 'connect-cluster',
  Array[String]    $bootstrap_servers                   = [ 'localhost:9092' ],
  String           $key_converter                       = 'org.apache.kafka.connect.json.JsonConverter',
  Boolean          $key_converter_schemas_enable        = true,
  String           $listeners                           = 'HTTP://:8083',
  String           $log4j_appender_file_path            = '/var/log/confluent/connect.log',
  String           $log4j_appender_max_file_size        = '100MB',
  Integer          $log4j_appender_max_backup_index     = 10,
  String           $log4j_loglevel_rootlogger           = 'INFO',
  String           $offset_flush_interval_ms            = '10000',
  String           $offset_storage_topic                = 'connect-offsets',
  String           $offset_storage_replication_factor   = '1',
  String           $offset_storage_partitions           = '25',
  String           $plugin_path                         = '/usr/share/java,/usr/share/confluent-hub-components',
  String           $status_storage_topic                = 'connect-status',
  String           $status_storage_replication_factor   = '1',
  String           $status_storage_partitions           = '5',
  String           $value_converter                     = 'org.apache.kafka.connect.json.JsonConverter',
  Optional[String] $value_converter_schema_registry_url = undef,
  Boolean          $value_converter_schemas_enable      = true,

  # kafka_connect::service
  String  $service_name   = 'confluent-kafka-connect',
  String  $service_ensure = 'running',
  Boolean $service_enable = true,

  # kafka_connect::manage_connectors
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

  if $include_java {
    include 'java'
  }

  if $manage_connectors_only {
    include 'kafka_connect::manage_connectors'
  } else {
    if $manage_confluent_repo {
      class { 'kafka_connect::confluent_repo':
        before  => Class['kafka_connect::install'],
      }
    }

    class { 'kafka_connect::install': }
    -> class { 'kafka_connect::config': }
    ~> class { 'kafka_connect::service': }
    -> class { 'kafka_connect::manage_connectors': }

    exec { 'wait_30s_for_service_start':
      command     => 'sleep 30',
      refreshonly => true,
      path        => ['/bin','/usr/bin','/usr/local/bin'],
      subscribe   => Class['kafka_connect::service'],
      before      => Class['kafka_connect::manage_connectors'],
    }
  }

}
