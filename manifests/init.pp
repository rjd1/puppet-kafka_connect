# @summary Main kafka_connect class.
#
# @param manage_connectors_only
#   Flag for including the connector management class only.
#
# @param manage_confluent_repo
#   Flag for including the confluent repo class.
#
# @param include_java
#   Flag for including class java.
#
# @param repo_ensure
#   Ensure value for the Confluent package repo resource.
#
# @param repo_enabled
#   Enabled value for the Confluent package repo resource.
#
# @param repo_version
#   Version of the Confluent repo to configure.
#
# @param package_name
#   Name of the main KC package to manage.
#
# @param package_ensure
#   State of the package to ensure.
#   Note that this may be used by more than one resource, depending on the setup.
#
# @param manage_schema_registry_package
#   Flag for managing the Schema Registry package.
#
# @param schema_registry_package_name
#   Name of the Schema Registry package.
#
# @param confluent_hub_plugin_path
#   Installation path for Confluent Hub plugins.
#
# @param confluent_hub_plugins
#   List of Confluent Hub plugins to install.
#   Each should be in the format author/name:semantic-version, e.g. 'acme/fancy-plugin:0.1.0'
#   Also accepts 'latest' in place of a specific version.
#
# @param confluent_hub_client_package_name
#   Name of the Confluent Hub Client package.
#
# @param confluent_common_package_name
#   Name of the Confluent Common package.
#
# @param kafka_heap_options
#   Value to set for 'KAFKA_HEAP_OPTS' export.
#
# @param kc_config_dir
#   Configuration directory for KC properties files.
#
# @param config_storage_replication_factor
#   Config value to set for 'config.storage.replication.factor'.
#
# @param config_storage_topic
#   Config value to set for 'config.storage.topic'.
#
# @param group_id
#   Config value to set for 'group.id'.
#
# @param bootstrap_servers
#   Config value to set for 'bootstrap.servers'.
#
# @param key_converter
#   Config value to set for 'key.converter'.
#
# @param key_converter_schemas_enable
#   Config value to set for 'key.converter.schemas.enable'.
#
# @param listeners
#   Config value to set for 'listeners'.
#
# @param log4j_file_appender
#   Log4j file appender type to use (RollingFileAppender or DailyRollingFileAppender).
#
# @param log4j_appender_file_path
#   Config value to set for 'log4j.appender.file.File'.
#
# @param log4j_appender_max_file_size
#   Config value to set for 'log4j.appender.file.MaxFileSize'.
#   Only used if log4j_file_appender = 'RollingFileAppender'.
#
# @param log4j_appender_max_backup_index
#   Config value to set for 'log4j.appender.file.MaxBackupIndex'.
#   Only used if log4j_file_appender = 'RollingFileAppender'.
#
# @param log4j_appender_date_pattern
#   Config value to set for 'log4j.appender.file.DatePattern'.
#   Only used if log4j_file_appender = 'DailyRollingFileAppender'.
#
# @param log4j_enable_stdout
#   Option to enable logging to stdout/console.
#
# @param log4j_custom_config_lines
#   Option to provide additional custom logging configuration.
#   Can be used, for example, to adjust the log level for a specific connector type.
#   See: https://docs.confluent.io/platform/current/connect/logging.html#use-the-kconnect-log4j-properties-file
#
# @param log4j_loglevel_rootlogger
#   Config value to set for 'log4j.rootLogger'.
#
# @param offset_flush_interval_ms
#   Config value to set for 'offset.flush.interval.ms'.
#
# @param offset_storage_topic
#   Config value to set for 'offset.storage.topic'.
#
# @param offset_storage_replication_factor
#   Config value to set for 'offset.storage.replication.factor'.
#
# @param offset_storage_partitions
#   Config value to set for 'offset.storage.partitions'.
#
# @param plugin_path
#   Config value to set for 'plugin.path'.
#
# @param status_storage_topic
#   Config value to set for 'status.storage.topic'.
#
# @param status_storage_replication_factor
#   Config value to set for 'status.storage.replication.factor'.
#
# @param status_storage_partitions
#   Config value to set for 'status.storage.partitions'.
#
# @param value_converter
#   Config value to set for 'value.converter'.
#
# @param value_converter_schema_registry_url
#   Config value to set for 'value.converter.schema.registry.url', if defined.
#
# @param value_converter_schemas_enable
#   Config value to set for 'value.converter.schemas.enable'.
#
# @param service_name
#   Name of the service to manage.
#
# @param service_ensure
#   State of the service to ensure.
#
# @param service_enable
#   Value for enabling the service at boot.
#
# @param connectors_absent
#   List of connectors to ensure absent.
#
# @param connectors_paused
#   List of connectors to ensure paused.
#
# @param connector_config_dir
#   Configuration directory for connector properties files.
#
# @param owner
#   Owner to set on config files.
#
# @param group
#   Group to set on config files.
#
# @param connector_config_file_mode
#   Mode to set on connector config file.
#
# @param connector_secret_file_mode
#   Mode to set on connector secret file.
#
# @param hostname
#   The hostname or IP of the KC service.
#
# @param rest_port
#   Port to connect to for the REST API.
#
# @param enable_delete
#   Enable delete of running connectors.
#   Required for the provider to actually remove when set to absent.
#
# @param restart_on_failed_state
#   Allow the provider to auto restart on FAILED connector state.
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
#     log4j_enable_stdout       => true,
#     log4j_custom_config_lines => [ 'log4j.logger.io.confluent.connect.elasticsearch=DEBUG' ],
#     confluent_hub_plugins     => [ 'confluentinc/kafka-connect-elasticsearch:latest' ],
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
  Boolean                     $manage_connectors_only              = false,
  Boolean                     $manage_confluent_repo               = true,
  Boolean                     $include_java                        = false,

  # kafka_connect::confluent_repo
  Enum['present', 'absent']   $repo_ensure                         = 'present',
  Boolean                     $repo_enabled                        = true,
  Pattern[/^(\d+\.\d+|\d+)$/] $repo_version                        = '7.5',

  # kafka_connect::install
  String[1]                   $package_name                        = 'confluent-kafka',
  String[1]                   $package_ensure                      = '7.5.1-1',
  Boolean                     $manage_schema_registry_package      = true,
  String[1]                   $schema_registry_package_name        = 'confluent-schema-registry',
  String[1]                   $confluent_rest_utils_package_name   = 'confluent-rest-utils',
  Stdlib::Absolutepath        $confluent_hub_plugin_path           = '/usr/share/confluent-hub-components',
  Kafka_connect::HubPlugins   $confluent_hub_plugins               = [],
  String[1]                   $confluent_hub_client_package_name   = 'confluent-hub-client',
  String[1]                   $confluent_common_package_name       = 'confluent-common',

  # kafka_connect::config
  String[1]                   $kafka_heap_options                  = '-Xms256M -Xmx2G',
  Stdlib::Absolutepath        $kc_config_dir                       = '/etc/kafka',
  Integer                     $config_storage_replication_factor   = 1,
  String[1]                   $config_storage_topic                = 'connect-configs',
  String[1]                   $group_id                            = 'connect-cluster',
  Array[String[1]]            $bootstrap_servers                   = [ 'localhost:9092' ],
  String[1]                   $key_converter                       = 'org.apache.kafka.connect.json.JsonConverter',
  Boolean                     $key_converter_schemas_enable        = true,
  Stdlib::HTTPUrl             $listeners                           = 'HTTP://:8083',
  Kafka_connect::LogAppender  $log4j_file_appender                 = 'RollingFileAppender',
  Stdlib::Absolutepath        $log4j_appender_file_path            = '/var/log/confluent/connect.log',
  String[1]                   $log4j_appender_max_file_size        = '100MB',
  Integer                     $log4j_appender_max_backup_index     = 10,
  String[1]                   $log4j_appender_date_pattern         = '\'.\'yyyy-MM-dd-HH',
  Boolean                     $log4j_enable_stdout                 = false,
  Optional[Array[String[1]]]  $log4j_custom_config_lines           = undef,
  Kafka_connect::Loglevel     $log4j_loglevel_rootlogger           = 'INFO',
  Integer                     $offset_flush_interval_ms            = 10000,
  String[1]                   $offset_storage_topic                = 'connect-offsets',
  Integer                     $offset_storage_replication_factor   = 1,
  Integer                     $offset_storage_partitions           = 25,
  Stdlib::Absolutepath        $plugin_path                         = '/usr/share/java,/usr/share/confluent-hub-components',
  String[1]                   $status_storage_topic                = 'connect-status',
  Integer                     $status_storage_replication_factor   = 1,
  Integer                     $status_storage_partitions           = 5,
  String[1]                   $value_converter                     = 'org.apache.kafka.connect.json.JsonConverter',
  Optional[Stdlib::HTTPUrl]   $value_converter_schema_registry_url = undef,
  Boolean                     $value_converter_schemas_enable      = true,

  # kafka_connect::service
  String[1]                   $service_name                        = 'confluent-kafka-connect',
  Stdlib::Ensure::Service     $service_ensure                      = 'running',
  Boolean                     $service_enable                      = true,

  # kafka_connect::manage_connectors
  Optional[Array[String[1]]]  $connectors_absent                   = undef,
  Optional[Array[String[1]]]  $connectors_paused                   = undef,
  Stdlib::Absolutepath        $connector_config_dir                = '/etc/kafka-connect',
  Variant[String[1], Integer] $owner                               = 'cp-kafka-connect',
  Variant[String[1], Integer] $group                               = 'confluent',
  Stdlib::Filemode            $connector_config_file_mode          = '0640',
  Stdlib::Filemode            $connector_secret_file_mode          = '0600',
  String[1]                   $hostname                            = 'localhost',
  Stdlib::Port                $rest_port                           = 8083,
  Boolean                     $enable_delete                       = false,
  Boolean                     $restart_on_failed_state             = false,
){

  if $include_java {
    include 'java'
  }

  if $manage_connectors_only {
    contain kafka_connect::manage_connectors
  } else {
    if $manage_confluent_repo {
      contain kafka_connect::confluent_repo

      Class['kafka_connect::confluent_repo']
      -> Class['kafka_connect::install']
    }

    contain kafka_connect::install
    contain kafka_connect::config
    contain kafka_connect::service
    contain kafka_connect::manage_connectors

    Class['kafka_connect::install']
    -> Class['kafka_connect::config']
    ~> Class['kafka_connect::service']
    -> Class['kafka_connect::manage_connectors']

    exec { 'wait_30s_for_service_start':
      command     => 'sleep 30',
      refreshonly => true,
      path        => ['/bin','/usr/bin','/usr/local/bin'],
      subscribe   => Class['kafka_connect::service'],
      before      => Class['kafka_connect::manage_connectors'],
    }
  }

}
