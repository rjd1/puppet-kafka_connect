# Reference

<!-- DO NOT EDIT: This document was generated by Puppet Strings -->

## Table of Contents

### Classes

#### Public Classes

* [`kafka_connect`](#kafka_connect): Main kafka_connect class.

#### Private Classes

* `kafka_connect::config`: Manages the Kafka Connect configuration.
* `kafka_connect::confluent_repo`: Manages the Confluent package repository.
* `kafka_connect::confluent_repo::apt`: Manages the Confluent apt package repository.
* `kafka_connect::confluent_repo::yum`: Manages the Confluent yum package repository.
* `kafka_connect::install`: Manages the Kafka Connect installation.
* `kafka_connect::manage_connectors`: Class to manage individual Kafka Connect connectors and connector secrets.
* `kafka_connect::manage_connectors::connector`: Class to manage individual Kafka Connect connectors.
* `kafka_connect::manage_connectors::secret`: Class to manage individual Kafka Connect connector secrets.
* `kafka_connect::service`: Manages the Kafka Connect service.

### Resource types

* [`kc_connector`](#kc_connector): Manage running Kafka Connect connectors.

### Data types

* [`Kafka_connect::Connector`](#kafka_connectconnector): Validate the individual connector data.
* [`Kafka_connect::Connectors`](#kafka_connectconnectors): Validate the connectors data.
* [`Kafka_connect::HubPlugins`](#kafka_connecthubplugins): Validate the Confluent Hub plugins list.
* [`Kafka_connect::LogAppender`](#kafka_connectlogappender): Validate the log4j file appender.
* [`Kafka_connect::Loglevel`](#kafka_connectloglevel): Matches all valid log4j loglevels.
* [`Kafka_connect::Secret`](#kafka_connectsecret): Validate the individual secret data.
* [`Kafka_connect::Secrets`](#kafka_connectsecrets): Validate the secrets data.

## Classes

### <a name="kafka_connect"></a>`kafka_connect`

Main kafka_connect class.

#### Examples

##### 

```puppet
include kafka_connect
```

##### 

```puppet
class { 'kafka_connect':
  config_storage_replication_factor   => 3,
  offset_storage_replication_factor   => 3,
  status_storage_replication_factor   => 3,
  bootstrap_servers                   => [ 'kafka-01:9092', 'kafka-02:9092', 'kafka-03:9092' ],
  confluent_hub_plugins               => [ 'confluentinc/kafka-connect-s3:10.5.7' ],
  value_converter_schema_registry_url => "http://schemaregistry-elb.${facts['networking']['domain']}:8081",
}
```

##### 

```puppet
class { 'kafka_connect':
  log4j_enable_stdout       => true,
  log4j_custom_config_lines => [ 'log4j.logger.io.confluent.connect.elasticsearch=DEBUG' ],
  confluent_hub_plugins     => [ 'confluentinc/kafka-connect-elasticsearch:latest' ],
}
```

##### 

```puppet
class { 'kafka_connect':
  manage_connectors_only => true,
  connector_config_dir   => '/opt/kafka-connect/etc',
  rest_port              => 8084,
  enable_delete          => true,
}
```

##### 

```puppet
class { 'kafka_connect':
  config_mode                   => 'standalone',
  run_local_kafka_broker_and_zk => true,
}
```

#### Parameters

The following parameters are available in the `kafka_connect` class:

* [`manage_connectors_only`](#manage_connectors_only)
* [`manage_confluent_repo`](#manage_confluent_repo)
* [`include_java`](#include_java)
* [`repo_ensure`](#repo_ensure)
* [`repo_enabled`](#repo_enabled)
* [`repo_version`](#repo_version)
* [`package_name`](#package_name)
* [`package_ensure`](#package_ensure)
* [`manage_schema_registry_package`](#manage_schema_registry_package)
* [`schema_registry_package_name`](#schema_registry_package_name)
* [`confluent_rest_utils_package_name`](#confluent_rest_utils_package_name)
* [`confluent_hub_plugin_path`](#confluent_hub_plugin_path)
* [`confluent_hub_plugins`](#confluent_hub_plugins)
* [`confluent_hub_client_package_name`](#confluent_hub_client_package_name)
* [`confluent_common_package_name`](#confluent_common_package_name)
* [`config_mode`](#config_mode)
* [`kafka_heap_options`](#kafka_heap_options)
* [`kc_config_dir`](#kc_config_dir)
* [`config_storage_replication_factor`](#config_storage_replication_factor)
* [`config_storage_topic`](#config_storage_topic)
* [`group_id`](#group_id)
* [`bootstrap_servers`](#bootstrap_servers)
* [`key_converter`](#key_converter)
* [`key_converter_schemas_enable`](#key_converter_schemas_enable)
* [`listeners`](#listeners)
* [`log4j_file_appender`](#log4j_file_appender)
* [`log4j_appender_file_path`](#log4j_appender_file_path)
* [`log4j_appender_max_file_size`](#log4j_appender_max_file_size)
* [`log4j_appender_max_backup_index`](#log4j_appender_max_backup_index)
* [`log4j_appender_date_pattern`](#log4j_appender_date_pattern)
* [`log4j_enable_stdout`](#log4j_enable_stdout)
* [`log4j_custom_config_lines`](#log4j_custom_config_lines)
* [`log4j_loglevel_rootlogger`](#log4j_loglevel_rootlogger)
* [`offset_storage_file_filename`](#offset_storage_file_filename)
* [`offset_flush_interval_ms`](#offset_flush_interval_ms)
* [`offset_storage_topic`](#offset_storage_topic)
* [`offset_storage_replication_factor`](#offset_storage_replication_factor)
* [`offset_storage_partitions`](#offset_storage_partitions)
* [`plugin_path`](#plugin_path)
* [`status_storage_topic`](#status_storage_topic)
* [`status_storage_replication_factor`](#status_storage_replication_factor)
* [`status_storage_partitions`](#status_storage_partitions)
* [`value_converter`](#value_converter)
* [`value_converter_schema_registry_url`](#value_converter_schema_registry_url)
* [`value_converter_schemas_enable`](#value_converter_schemas_enable)
* [`run_local_kafka_broker_and_zk`](#run_local_kafka_broker_and_zk)
* [`service_name`](#service_name)
* [`service_ensure`](#service_ensure)
* [`service_enable`](#service_enable)
* [`service_provider`](#service_provider)
* [`connectors_absent`](#connectors_absent)
* [`connectors_paused`](#connectors_paused)
* [`connector_config_dir`](#connector_config_dir)
* [`owner`](#owner)
* [`group`](#group)
* [`connector_config_file_mode`](#connector_config_file_mode)
* [`connector_secret_file_mode`](#connector_secret_file_mode)
* [`hostname`](#hostname)
* [`rest_port`](#rest_port)
* [`enable_delete`](#enable_delete)
* [`restart_on_failed_state`](#restart_on_failed_state)

##### <a name="manage_connectors_only"></a>`manage_connectors_only`

Data type: `Boolean`

Flag for including the connector management class only.

Default value: ``false``

##### <a name="manage_confluent_repo"></a>`manage_confluent_repo`

Data type: `Boolean`

Flag for including the confluent repo class.

Default value: ``true``

##### <a name="include_java"></a>`include_java`

Data type: `Boolean`

Flag for including class java.

Default value: ``false``

##### <a name="repo_ensure"></a>`repo_ensure`

Data type: `Enum['present', 'absent']`

Ensure value for the Confluent package repo resource.

Default value: `'present'`

##### <a name="repo_enabled"></a>`repo_enabled`

Data type: `Boolean`

Enabled value for the Confluent package repo resource.

Default value: ``true``

##### <a name="repo_version"></a>`repo_version`

Data type: `Pattern[/^(\d+\.\d+|\d+)$/]`

Version of the Confluent repo to configure.

Default value: `'7.5'`

##### <a name="package_name"></a>`package_name`

Data type: `String[1]`

Name of the main KC package to manage.

Default value: `'confluent-kafka'`

##### <a name="package_ensure"></a>`package_ensure`

Data type: `String[1]`

State of the package to ensure.
Note that this may be used by more than one resource, depending on the setup.

Default value: `'7.5.1-1'`

##### <a name="manage_schema_registry_package"></a>`manage_schema_registry_package`

Data type: `Boolean`

Flag for managing the Schema Registry package (and REST Utils dependency package).

Default value: ``true``

##### <a name="schema_registry_package_name"></a>`schema_registry_package_name`

Data type: `String[1]`

Name of the Schema Registry package.

Default value: `'confluent-schema-registry'`

##### <a name="confluent_rest_utils_package_name"></a>`confluent_rest_utils_package_name`

Data type: `String[1]`

Name of the Confluent REST Utils package.

Default value: `'confluent-rest-utils'`

##### <a name="confluent_hub_plugin_path"></a>`confluent_hub_plugin_path`

Data type: `Stdlib::Absolutepath`

Installation path for Confluent Hub plugins.

Default value: `'/usr/share/confluent-hub-components'`

##### <a name="confluent_hub_plugins"></a>`confluent_hub_plugins`

Data type: `Kafka_connect::HubPlugins`

List of Confluent Hub plugins to install.
Each should be in the format author/name:semantic-version, e.g. 'acme/fancy-plugin:0.1.0'
Also accepts 'latest' in place of a specific version.

Default value: `[]`

##### <a name="confluent_hub_client_package_name"></a>`confluent_hub_client_package_name`

Data type: `String[1]`

Name of the Confluent Hub Client package.

Default value: `'confluent-hub-client'`

##### <a name="confluent_common_package_name"></a>`confluent_common_package_name`

Data type: `String[1]`

Name of the Confluent Common package.

Default value: `'confluent-common'`

##### <a name="config_mode"></a>`config_mode`

Data type: `Enum['distributed', 'standalone']`

Configuration mode to use for the setup.

Default value: `'distributed'`

##### <a name="kafka_heap_options"></a>`kafka_heap_options`

Data type: `String[1]`

Value to set for 'KAFKA_HEAP_OPTS' export.

Default value: `'-Xms256M -Xmx2G'`

##### <a name="kc_config_dir"></a>`kc_config_dir`

Data type: `Stdlib::Absolutepath`

Configuration directory for KC properties files.

Default value: `'/etc/kafka'`

##### <a name="config_storage_replication_factor"></a>`config_storage_replication_factor`

Data type: `Integer`

Config value to set for 'config.storage.replication.factor'.

Default value: `1`

##### <a name="config_storage_topic"></a>`config_storage_topic`

Data type: `String[1]`

Config value to set for 'config.storage.topic'.

Default value: `'connect-configs'`

##### <a name="group_id"></a>`group_id`

Data type: `String[1]`

Config value to set for 'group.id'.

Default value: `'connect-cluster'`

##### <a name="bootstrap_servers"></a>`bootstrap_servers`

Data type: `Array[String[1]]`

Config value to set for 'bootstrap.servers'.

Default value: `['localhost:9092']`

##### <a name="key_converter"></a>`key_converter`

Data type: `String[1]`

Config value to set for 'key.converter'.

Default value: `'org.apache.kafka.connect.json.JsonConverter'`

##### <a name="key_converter_schemas_enable"></a>`key_converter_schemas_enable`

Data type: `Boolean`

Config value to set for 'key.converter.schemas.enable'.

Default value: ``true``

##### <a name="listeners"></a>`listeners`

Data type: `Stdlib::HTTPUrl`

Config value to set for 'listeners'.

Default value: `'HTTP://:8083'`

##### <a name="log4j_file_appender"></a>`log4j_file_appender`

Data type: `Kafka_connect::LogAppender`

Log4j file appender type to use (RollingFileAppender or DailyRollingFileAppender).

Default value: `'RollingFileAppender'`

##### <a name="log4j_appender_file_path"></a>`log4j_appender_file_path`

Data type: `Stdlib::Absolutepath`

Config value to set for 'log4j.appender.file.File'.

Default value: `'/var/log/confluent/connect.log'`

##### <a name="log4j_appender_max_file_size"></a>`log4j_appender_max_file_size`

Data type: `String[1]`

Config value to set for 'log4j.appender.file.MaxFileSize'.
Only used if log4j_file_appender = 'RollingFileAppender'.

Default value: `'100MB'`

##### <a name="log4j_appender_max_backup_index"></a>`log4j_appender_max_backup_index`

Data type: `Integer`

Config value to set for 'log4j.appender.file.MaxBackupIndex'.
Only used if log4j_file_appender = 'RollingFileAppender'.

Default value: `10`

##### <a name="log4j_appender_date_pattern"></a>`log4j_appender_date_pattern`

Data type: `String[1]`

Config value to set for 'log4j.appender.file.DatePattern'.
Only used if log4j_file_appender = 'DailyRollingFileAppender'.

Default value: `'\'.\'yyyy-MM-dd-HH'`

##### <a name="log4j_enable_stdout"></a>`log4j_enable_stdout`

Data type: `Boolean`

Option to enable logging to stdout/console.

Default value: ``false``

##### <a name="log4j_custom_config_lines"></a>`log4j_custom_config_lines`

Data type: `Optional[Array[String[1]]]`

Option to provide additional custom logging configuration.
Can be used, for example, to adjust the log level for a specific connector type.
See: https://docs.confluent.io/platform/current/connect/logging.html#use-the-kconnect-log4j-properties-file

Default value: ``undef``

##### <a name="log4j_loglevel_rootlogger"></a>`log4j_loglevel_rootlogger`

Data type: `Kafka_connect::Loglevel`

Config value to set for 'log4j.rootLogger'.

Default value: `'INFO'`

##### <a name="offset_storage_file_filename"></a>`offset_storage_file_filename`

Data type: `String[1]`

Config value to set for 'offset.storage.file.filename'.
Only used in standalone mode.

Default value: `'/tmp/connect.offsets'`

##### <a name="offset_flush_interval_ms"></a>`offset_flush_interval_ms`

Data type: `Integer`

Config value to set for 'offset.flush.interval.ms'.

Default value: `10000`

##### <a name="offset_storage_topic"></a>`offset_storage_topic`

Data type: `String[1]`

Config value to set for 'offset.storage.topic'.

Default value: `'connect-offsets'`

##### <a name="offset_storage_replication_factor"></a>`offset_storage_replication_factor`

Data type: `Integer`

Config value to set for 'offset.storage.replication.factor'.

Default value: `1`

##### <a name="offset_storage_partitions"></a>`offset_storage_partitions`

Data type: `Integer`

Config value to set for 'offset.storage.partitions'.

Default value: `25`

##### <a name="plugin_path"></a>`plugin_path`

Data type: `Stdlib::Absolutepath`

Config value to set for 'plugin.path'.

Default value: `'/usr/share/java,/usr/share/confluent-hub-components'`

##### <a name="status_storage_topic"></a>`status_storage_topic`

Data type: `String[1]`

Config value to set for 'status.storage.topic'.

Default value: `'connect-status'`

##### <a name="status_storage_replication_factor"></a>`status_storage_replication_factor`

Data type: `Integer`

Config value to set for 'status.storage.replication.factor'.

Default value: `1`

##### <a name="status_storage_partitions"></a>`status_storage_partitions`

Data type: `Integer`

Config value to set for 'status.storage.partitions'.

Default value: `5`

##### <a name="value_converter"></a>`value_converter`

Data type: `String[1]`

Config value to set for 'value.converter'.

Default value: `'org.apache.kafka.connect.json.JsonConverter'`

##### <a name="value_converter_schema_registry_url"></a>`value_converter_schema_registry_url`

Data type: `Optional[Stdlib::HTTPUrl]`

Config value to set for 'value.converter.schema.registry.url', if defined.

Default value: ``undef``

##### <a name="value_converter_schemas_enable"></a>`value_converter_schemas_enable`

Data type: `Boolean`

Config value to set for 'value.converter.schemas.enable'.

Default value: ``true``

##### <a name="run_local_kafka_broker_and_zk"></a>`run_local_kafka_broker_and_zk`

Data type: `Boolean`

Flag for running local kafka broker and zookeeper services.
Intended only for use with standalone config mode.

Default value: ``false``

##### <a name="service_name"></a>`service_name`

Data type: `String[1]`

Name of the service to manage.

Default value: `'confluent-kafka-connect'`

##### <a name="service_ensure"></a>`service_ensure`

Data type: `Stdlib::Ensure::Service`

State of the service to ensure.

Default value: `'running'`

##### <a name="service_enable"></a>`service_enable`

Data type: `Boolean`

Value for enabling the service at boot.

Default value: ``true``

##### <a name="service_provider"></a>`service_provider`

Data type: `Optional[String[1]]`

Backend provider to use for the service resource.

Default value: ``undef``

##### <a name="connectors_absent"></a>`connectors_absent`

Data type: `Optional[Array[String[1]]]`

List of connectors to ensure absent.
*Deprecated*: use the 'ensure' hash key in the connector data instead.

Default value: ``undef``

##### <a name="connectors_paused"></a>`connectors_paused`

Data type: `Optional[Array[String[1]]]`

List of connectors to ensure paused.
*Deprecated*: use the 'ensure' hash key in the connector data instead.

Default value: ``undef``

##### <a name="connector_config_dir"></a>`connector_config_dir`

Data type: `Stdlib::Absolutepath`

Configuration directory for connector properties files.

Default value: `'/etc/kafka-connect'`

##### <a name="owner"></a>`owner`

Data type: `Variant[String[1], Integer]`

Owner to set on config files.

Default value: `'cp-kafka-connect'`

##### <a name="group"></a>`group`

Data type: `Variant[String[1], Integer]`

Group to set on config files.

Default value: `'confluent'`

##### <a name="connector_config_file_mode"></a>`connector_config_file_mode`

Data type: `Stdlib::Filemode`

Mode to set on connector config file.

Default value: `'0640'`

##### <a name="connector_secret_file_mode"></a>`connector_secret_file_mode`

Data type: `Stdlib::Filemode`

Mode to set on connector secret file.

Default value: `'0600'`

##### <a name="hostname"></a>`hostname`

Data type: `String[1]`

The hostname or IP of the KC service.

Default value: `'localhost'`

##### <a name="rest_port"></a>`rest_port`

Data type: `Stdlib::Port`

Port to connect to for the REST API.

Default value: `8083`

##### <a name="enable_delete"></a>`enable_delete`

Data type: `Boolean`

Enable delete of running connectors.
Required for the provider to actually remove when set to absent.

Default value: ``false``

##### <a name="restart_on_failed_state"></a>`restart_on_failed_state`

Data type: `Boolean`

Allow the provider to auto restart on FAILED connector state.

Default value: ``false``

## Resource types

### <a name="kc_connector"></a>`kc_connector`

Manage running Kafka Connect connectors.

#### Properties

The following properties are available in the `kc_connector` type.

##### `config_updated`

Valid values: `yes`, `no`, `unknown`

Property to ensure running config matches file config.

Default value: `yes`

##### `connector_state_ensure`

Valid values: `RUNNING`, `PAUSED`

State of the connector to ensure.

Default value: `RUNNING`

##### `ensure`

Valid values: `present`, `absent`

The basic property that the resource should be in.

Default value: `present`

##### `tasks_state_ensure`

Valid values: `RUNNING`

State of the connector tasks to ensure. This is just used to catch failed tasks and should not be changed.

Default value: `RUNNING`

#### Parameters

The following parameters are available in the `kc_connector` type.

* [`config_file`](#config_file)
* [`enable_delete`](#enable_delete)
* [`hostname`](#hostname)
* [`name`](#name)
* [`port`](#port)
* [`provider`](#provider)
* [`restart_on_failed_state`](#restart_on_failed_state)

##### <a name="config_file"></a>`config_file`

Config file fully qualified path.

##### <a name="enable_delete"></a>`enable_delete`

Valid values: ``true``, ``false``, `yes`, `no`

Flag to enable delete, required for remove action.

Default value: ``false``

##### <a name="hostname"></a>`hostname`

The hostname or IP of the KC service.

Default value: `localhost`

##### <a name="name"></a>`name`

namevar

The name of the connector resource you want to manage.

##### <a name="port"></a>`port`

The listening port of the KC service.

Default value: `8083`

##### <a name="provider"></a>`provider`

The specific backend to use for this `kc_connector` resource. You will seldom need to specify this --- Puppet will
usually discover the appropriate provider for your platform.

##### <a name="restart_on_failed_state"></a>`restart_on_failed_state`

Valid values: ``true``, ``false``, `yes`, `no`

Flag to enable auto restart on FAILED connector state.

Default value: ``false``

## Data types

### <a name="kafka_connectconnector"></a>`Kafka_connect::Connector`

Validate the individual connector data.

Alias of

```puppet
Struct[{
    Optional['ensure'] => Enum['absent', 'present', 'running', 'paused'],
    'name'             => String[1],
    Optional['config'] => Hash[String[1], String],
  }]
```

### <a name="kafka_connectconnectors"></a>`Kafka_connect::Connectors`

Validate the connectors data.

Alias of

```puppet
Hash[String[1], Kafka_connect::Connector]
```

### <a name="kafka_connecthubplugins"></a>`Kafka_connect::HubPlugins`

Validate the Confluent Hub plugins list.

Alias of

```puppet
Array[Optional[Pattern[/^\w+\/[a-zA-z0-9]{1,}[a-zA-z0-9\-]{0,}:(\d+\.\d+\.\d+|latest)$/]]]
```

### <a name="kafka_connectlogappender"></a>`Kafka_connect::LogAppender`

Validate the log4j file appender.

Alias of

```puppet
Enum['DailyRollingFileAppender', 'RollingFileAppender']
```

### <a name="kafka_connectloglevel"></a>`Kafka_connect::Loglevel`

Matches all valid log4j loglevels.

Alias of

```puppet
Enum['TRACE', 'DEBUG', 'INFO', 'WARN', 'ERROR', 'FATAL']
```

### <a name="kafka_connectsecret"></a>`Kafka_connect::Secret`

Validate the individual secret data.

Alias of

```puppet
Struct[{
    Optional['ensure']     => Enum['absent', 'present', 'file'],
    Optional['connectors'] => Array[String[1]],
    Optional['key']        => String[1],
    Optional['value']      => String[1],
    Optional['kv_data']    => Hash[String[1], String[1]],
  }]
```

### <a name="kafka_connectsecrets"></a>`Kafka_connect::Secrets`

Validate the secrets data.

Alias of

```puppet
Hash[String[1], Kafka_connect::Secret]
```

