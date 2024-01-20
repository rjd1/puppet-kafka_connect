# Main kafka_connect class.
#
# @param manage_connectors_only
# @param manage_confluent_repo
# @param include_java
# @param repo_ensure
# @param repo_enabled
# @param repo_version
# @param package_name
# @param package_ensure
# @param manage_schema_registry_package
# @param schema_registry_package_name
# @param confluent_hub_plugin_path
# @param confluent_hub_plugins
# @param confluent_hub_client_package_name
# @param confluent_common_package_name
# @param kafka_heap_options
# @param config_storage_replication_factor
# @param config_storage_topic
# @param group_id
# @param bootstrap_servers
# @param key_converter
# @param key_converter_schemas_enable
# @param listeners
# @param log4j_appender_file_path
# @param log4j_appender_max_file_size
# @param log4j_appender_max_backup_index
# @param log4j_loglevel_rootlogger
# @param offset_flush_interval_ms
# @param offset_storage_topic
# @param offset_storage_replication_factor
# @param offset_storage_partitions
# @param plugin_path
# @param status_storage_topic
# @param status_storage_replication_factor
# @param status_storage_partitions
# @param value_converter
# @param value_converter_schema_registry_url
# @param value_converter_schemas_enable
# @param service_name
# @param service_ensure
# @param service_enable
# @param connectors_absent
# @param connectors_paused
# @param connector_config_dir
# @param owner
# @param group
# @param connector_config_file_mode
# @param connector_secret_file_mode
# @param hostname
# @param rest_port
# @param enable_delete
# @param restart_on_failed_state
#
# @example
#   include kafka_connect
#
# @example
#   class { 'kafka_connect':
#     config_storage_replication_factor   => 3,
#     offset_storage_replication_factor   => 3,
#     status_storage_replication_factor   => 3,
#     bootstrap_servers                   => [ 'kafka-01:9092', 'kafka-02:9092', 'kafka-03:9092' ],
#     confluent_hub_plugins               => [ 'confluentinc/kafka-connect-s3:10.5.7' ],
#     value_converter_schema_registry_url => "http://schemaregistry-elb.${facts['networking']['domain']}:8081",
#   }
#
# @example
#   class { 'kafka_connect':
#     manage_connectors_only => true,
#     connector_config_dir   => '/opt/kafka-connect/etc',
#     rest_port              => 8084,
#     enable_delete          => true,
#   }
#
# @author https://github.com/rjd1/puppet-kafka_connect/graphs/contributors
#
class kafka_connect (
  # kafka_connect
  Boolean                       $manage_connectors_only              = false,
  Boolean                       $manage_confluent_repo               = true,
  Boolean                       $include_java                        = false,

  # kafka_connect::confluent_repo
  Enum['present', 'absent']     $repo_ensure                         = 'present',
  Boolean                       $repo_enabled                        = true,
  Pattern[/^(\d+\.\d+|\d+)$/]   $repo_version                        = '7.5',

  # kafka_connect::install
  String[1]                     $package_name                        = 'confluent-kafka',
  Kafka_connect::Package_ensure $package_ensure                      = '7.5.1-1',
  Boolean                       $manage_schema_registry_package      = true,
  String[1]                     $schema_registry_package_name        = 'confluent-schema-registry',
  String[1]                     $confluent_rest_utils_package_name   = 'confluent-rest-utils',
  Stdlib::Absolutepath          $confluent_hub_plugin_path           = '/usr/share/confluent-hub-components',
  Array[String]                 $confluent_hub_plugins               = [],
  String[1]                     $confluent_hub_client_package_name   = 'confluent-hub-client',
  String[1]                     $confluent_common_package_name       = 'confluent-common',

  # kafka_connect::config
  String[1]                     $kafka_heap_options                  = '-Xms256M -Xmx2G',
  Integer                       $config_storage_replication_factor   = 1,
  String[1]                     $config_storage_topic                = 'connect-configs',
  String[1]                     $group_id                            = 'connect-cluster',
  Array[String[1]]              $bootstrap_servers                   = [ 'localhost:9092' ],
  String[1]                     $key_converter                       = 'org.apache.kafka.connect.json.JsonConverter',
  Boolean                       $key_converter_schemas_enable        = true,
  Stdlib::HTTPUrl               $listeners                           = 'HTTP://:8083',
  Stdlib::Absolutepath          $log4j_appender_file_path            = '/var/log/confluent/connect.log',
  String[1]                     $log4j_appender_max_file_size        = '100MB',
  Integer                       $log4j_appender_max_backup_index     = 10,
  String[1]                     $log4j_loglevel_rootlogger           = 'INFO',
  Integer                       $offset_flush_interval_ms            = 10000,
  String[1]                     $offset_storage_topic                = 'connect-offsets',
  Integer                       $offset_storage_replication_factor   = 1,
  Integer                       $offset_storage_partitions           = 25,
  Stdlib::Absolutepath          $plugin_path                         = '/usr/share/java,/usr/share/confluent-hub-components',
  String[1]                     $status_storage_topic                = 'connect-status',
  Integer                       $status_storage_replication_factor   = 1,
  Integer                       $status_storage_partitions           = 5,
  String[1]                     $value_converter                     = 'org.apache.kafka.connect.json.JsonConverter',
  Optional[Stdlib::HTTPUrl]     $value_converter_schema_registry_url = undef,
  Boolean                       $value_converter_schemas_enable      = true,

  # kafka_connect::service
  String[1]                     $service_name                        = 'confluent-kafka-connect',
  Stdlib::Ensure::Service       $service_ensure                      = 'running',
  Boolean                       $service_enable                      = true,

  # kafka_connect::manage_connectors
  Optional[Array[String[1]]]    $connectors_absent                   = undef,
  Optional[Array[String[1]]]    $connectors_paused                   = undef,
  Stdlib::Absolutepath          $connector_config_dir                = '/etc/kafka-connect',
  String[1]                     $owner                               = 'cp-kafka-connect',
  String[1]                     $group                               = 'confluent',
  Stdlib::Filemode              $connector_config_file_mode          = '0640',
  Stdlib::Filemode              $connector_secret_file_mode          = '0600',
  String[1]                     $hostname                            = 'localhost',
  Stdlib::Port                  $rest_port                           = 8083,
  Boolean[1]                    $enable_delete                       = false,
  Boolean[1]                    $restart_on_failed_state             = false,
){

  if $include_java {
    include 'java'
  }

  if $manage_connectors_only {
    include 'kafka_connect::manage_connectors'
  } else {
    if $manage_confluent_repo {
      class { 'kafka_connect::confluent_repo':
        before => Class['kafka_connect::install'],
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
