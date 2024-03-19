# kafka_connect

[![Puppet Forge](https://img.shields.io/puppetforge/v/rjd1/kafka_connect.svg)](https://forge.puppetlabs.com/rjd1/kafka_connect)
[![puppetmodule.info docs](http://www.puppetmodule.info/images/badge.png)](http://www.puppetmodule.info/m/rjd1-kafka_connect)
[![License](https://img.shields.io/github/license/rjd1/puppet-kafka_connect.svg)](https://github.com/rjd1/puppet-kafka_connect/blob/master/LICENSE)

Welcome to the kafka_connect Puppet module!

## Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with kafka_connect](#setup)
    * [What kafka_connect affects](#what-kafka_connect-affects)
    * [Getting started with_kafka_connect](#getting-started-with-kafka_connect)
3. [Usage - Configuration options and additional functionality](#usage)
    * [Typical deployment](#typical-deployment)
    * [Managing connectors through the helper class](#managing-connectors-through-the-helper-class)
    * * [Add a connector](#add-a-connector)
    * * [Update an existing connector](#update-an-existing-connector)
    * * [Remove a connector](#remove-a-connector)
    * * [Pause a connector](#pause-a-connector)
    * * [Managing secrets config data](#managing-secrets-config-data)
    * [Managing connectors directly through the resource type](#managing-connectors-directly-through-the-resource-type)
    * * [WARNING: Breaking change in v2.0.0](#warning-breaking-change-in-v2.0.0)
    * * [Examples](#examples)
4. [Reference - An under-the-hood peek at what the module is doing and how](REFERENCE.md)
5. [Limitations - OS compatibility, etc.](#limitations)
    * [Known Issues](#known-issues)
6. [Development - Guide for contributing to the module](#development)

## Description

Manages the setup of Kafka Connect.

Includes a Type, Provider, and helper class for management of individual KC connectors.

## Setup

### What kafka_connect affects

* Manages the KC installation, configuration, and system service.
* Manages the individual state of running connectors, + their config & secret files.

### Getting started with kafka_connect

For a basic Kafka Connect system setup with the default settings, declare the `kafka_connect` class.

```puppet
class { 'kafka_connect': }
```

## Usage

### Typical deployment

For a typical distributed mode deployment, most of the default settings should be fine. However, a normal setup will involve connecting to a cluster of Kafka brokers and the replication factor config values for storage topics should be increased. Here is a real-world example that also specifies version and includes the Confluent JDBC plugin:

```puppet
  class { 'kafka_connect':
    config_storage_replication_factor => 3,
    offset_storage_replication_factor => 3,
    status_storage_replication_factor => 3,
    bootstrap_servers                 => [
      "kafka-01.${facts['networking']['domain']}:9092",
      "kafka-02.${facts['networking']['domain']}:9092",
      "kafka-03.${facts['networking']['domain']}:9092",
      "kafka-04.${facts['networking']['domain']}:9092",
      "kafka-05.${facts['networking']['domain']}:9092"
    ],
    confluent_hub_plugins             => [ 'confluentinc/kafka-connect-jdbc:10.7.4' ],
    package_ensure                    => '7.5.2-1',
  }
```

### Managing connectors through the helper class

The helper class is designed to work with connector data defined in hiera.

The main class needs to be included/declared. If only the connector management functionality is desired, there's a flag to exclude the standard setup stuff:

```puppet
  class { 'kafka_connect':
    manage_connectors_only => true,
  }
```

The following sections provide examples of specific functionality through hiera data.

#### Add a Connector

The connector config data should be added to hiera with the following layout.

```yaml
kafka_connect::connectors:
  my-connector.json:
    name: 'my-kc-connector'
    config:
      my.config.key: "value"
      my.other.config: "other_value"
```

#### Update an existing Connector

Simply make changes to the connector `config` hash, as needed.

```yaml
kafka_connect::connectors:
  my-connector.json:
    name: 'my-kc-connector'
    config:
      my.config.key: "new_value"
      my.other.config: "other_new_value"
```

#### Remove a Connector

There's a parameter, `enable_delete`, that by default is set to false and must first be overwritten to support this. Then use the optional `ensure` key in the connector data hash and set it to 'absent'.

```yaml
kafka_connect::enable_delete: true
kafka_connect::connectors:
  my-connector.json:
    name: 'my-jdbc-connector'
    ensure: 'absent'
```

NOTE: be sure to remove it from the secrets array list as well, if present.

#### Pause a Connector

The provider supports ensuring the connector state is either running (default) or paused. Similar to removing, use the `ensure` key in the connector data hash and set it to 'paused'.

```yaml
kafka_connect::connectors:
  my-connector.json:
    name: 'my-jdbc-connector'
    ensure: 'paused'
    config:
      my.config.key: "value"
      my.other.config: "other_value"
```

Remove the ensure line or set it to 'running' to unpause/resume.

#### Managing Secrets Config Data

Support for [Externalized Secrets](https://docs.confluent.io/platform/current/connect/security.html#externalize-secrets) is provided through `kafka_connect::secrets`. This enables things like database passwords, etc., to be separated from the normal config and just loaded into memory when the connector starts.

The following is a basic DB connection example defined in YAML.

```yaml
kafka_connect::connectors:
  my-connector.json:
    name: 'my-jdbc-connector'
    config:
      connection.url: "jdbc:postgresql://some-host.example.com:5432/db"
      connection.user: "my-user"
      connection.password: "${file:/etc/kafka-connect/my-jdbc-secret-file.properties:jdbc-sink-connection-password}"
```

The password is then added, preferably via [EYAML](https://github.com/voxpupuli/hiera-eyaml), with the file and var names used in the config.

```yaml
kafka_connect::secrets:
  my-jdbc-secret-file.properties:
    connectors:
      - 'my-jdbc-connector'
    key: 'jdbc-sink-connection-password'
    value: 'ENC[PKCS7,encrypted-passwd-value]'
```

The `connectors` array should contain a list of connector names that reference it in the config. This allows for automatic update/refresh (via REST API restart POST) if the password value is changed.

To later remove unused files, use the optional `ensure` hash key and set it to 'absent'.

```yaml
kafka_connect::secrets:
  my-old-jdbc-secret-file.properties:
    ensure: 'absent'
```

### Managing connectors directly through the resource type

#### WARNING: Breaking change in v2.0.0

In release v2.0.0 the type and provider were renamed from `manage_connector` to `kc_connector`. Usage and functionality remain the same.

#### Examples

Ensure a connector exists and the running config matches the file config:

```puppet
  kc_connector { 'some-kc-connector-name' :
    ensure      => 'present',
    config_file => '/etc/kafka-connect/some-kc-connector.properties.json',
    port        => 8084,
  }
```

To pause:

```puppet
  kc_connector { 'some-kc-connector-name' :
    connector_state_ensure => 'PAUSED',
  }
```

To remove:

```puppet
  kc_connector { 'some-kc-connector-name' :
    ensure        => 'absent',
    enable_delete => true,
  }
```

Command to remove through the Puppet RAL:

```bash
$ puppet resource kc_connector some-kc-connector-name ensure=absent enable_delete=true
```

## Limitations

Tested with Confluent 7.x on Amazon Linux 2. Should also work on other RedHat as well as Debian-based systems.

Each secrets file should contain only one key-value pair.

Currently only distributed mode setup is supported.

### Known Issues

When the `enable_delete` parameter is set to false and a connector is set to absent, Puppet still says there is a removal (i.e., lies). A similar situation occurs with the `config_updated` property when both it and `config_file` are not specified. There are warnings output along with the notices in these scenarios.

## Development

The project is held at GitHub:
 
* [https://github.com/rjd1/puppet-kafka_connect](https://github.com/rjd1/puppet-kafka_connect)
 
Issue reports and pull requests are welcome.
