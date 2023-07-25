# kafka_connect

Welcome to the kafka_connect Puppet module!

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with kafka_connect](#setup)
    * [What kafka_connect affects](#what-kafka_connect-affects)
1. [Usage - Configuration options and additional functionality](#usage)
    * [Using the provider directly](#using-the-provider-directly)
    * * [Examples](#examples)
    * [Managing connectors through the helper class](#managing-connectors-through-the-helper-class)
    * * [Add a Connector](#add-a-connector)
    * * [Update an existing Connector](#update-an-existing-connector)
    * * [Remove a Connector](#remove-a-connector)
    * * [Pause a Connector](#pause-a-connector)
    * * [Add Secrets Config Data](#add-secrets-config-data)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

Type, Provider, and helper class for management of individual Kafka Connect connectors.

Note that this module *does not* (at present) manage the actual KC installation and service setup.

## Setup

### What kafka_connect affects

* Manages the individual state of running connectors.
* Optionally manages connector config & secret files.

## Usage

### Using the provider directly

#### Examples

Ensure a connector exists and the running config matches the file config:

```puppet
  manage_connector { 'some-kc-connector' :
    ensure      => 'present',
    config_file => '/etc/kafka-connect/some-kc-connector.properties.json',
    port        => 8084,
  }
```

To pause:

```puppet
  manage_connector { 'some-kc-connector' :
    ensure                 => 'present',
    config_file            => '/etc/kafka-connect/some-kc-connector.properties.json',
    connector_state_ensure => 'PAUSED',
  }
```
To remove:

```puppet
  manage_connector { 'some-kc-connector' :
    ensure        => 'absent',
    enable_delete => true,
  }
```

### Managing connectors through the helper class

The helper class is designed to work with connector data defined in hiera.

First include the main class. The following sections provide examples of specific functionality thru hiera data.

```puppet
include kafka_connect
```

#### Add a Connector

The connector config data should be added to hiera with the following layout.

**NOTE:** boolean and integer values must be quoted. This is important in order to avoid a situation where Puppet wants to constantly update the connector, due to the comparison done between file config & live connector.

```yaml
kafka_connect::connectors:
  my-connector.json:
    name: 'my-kc-connector'
    config:
      my.config.key: "value"
      my.other.config: "other_value"
```

#### Update an existing Connector

Simply make changes to the connector config hash, as needed.

```yaml
kafka_connect::connectors:
  my-connector.json:
    name: 'my-kc-connector'
    config:
      my.config.key: "new_value"
      my.other.config: "other_new_value"
```

#### Remove a Connector

There's a parameter, `enable_delete`, that by default is set to false and must first be overwritten to support this. Then add the connector(s) to remove to the `connectors_absent` array (leave the previously added config data in place, in order for the file to be removed effectively).

```yaml
kafka_connect::enable_delete: true
kafka_connect::connectors_absent:
  - 'my-kc-connector'
kafka_connect::connectors:
  my-connector.json:
    name: 'my-kc-connector'
    config:
      my.config.key: "value"
      my.other.config: "other_value"
```

**NOTE:** be sure to remove it from the secrets array list as well, if present.

#### Pause a Connector

The provider supports ensuring the connector state is either running (default) or paused. Similar to removing, provide a list of connector(s) to pause to the parameter array `connectors_paused`.

```yaml
kafka_connect::connectors_paused:
  - 'some-connector-name'
```

Remove from the list to unpause/resume.

#### Add Secrets Config Data

Support for [Externalizing Secrets](https://docs.confluent.io/platform/current/connect/security.html#externalizing-secrets) is provided through `kafka_connect::secrets`. This enables things like database passwords, etc., to be separated from the normal config and just loaded into memory when the connector starts.

The following is a basic DB connection example defined in YAML.

```yaml
kafka_connect::connectors:
  my-connector.json:
    name: 'my-jdbc-connector'
    config:
      connection.url: "jdbc:postgresql://some-host.example.com:5432/db"
      connection.user: "my-user"
      connection.password: "${file:/etc/kafka-connect/my-jdbc-secrets-file.properties:jdbc-sink-connection-password}"
```

The password is then added, preferably via [EYAML](https://github.com/voxpupuli/hiera-eyaml), with the file and var names used in the config.

```yaml
kafka_connect::secrets:
  my-jdbc-secrets-file.properties:
    connectors:
      - 'my-jdbc-connector'
    key: 'jdbc-sink-connection-password'
    value: 'ENC[PKCS7,encrypted-passwd-value]'
```

The `connectors` array should contain a list of connector names that reference it in the config. This allows for automatic update/refresh (via REST API restart POST) if the password value is changed.

## Limitations

Tested with Confluent 7.1.1 on Amazon Linux 2.

In order to remove a connector thru hiera, the config put in place during the add step must remain. This is necessary for the config file to be removed along with the live connector.

When the `enable_delete` parameter is set to false and a connector is set to absent, Puppet still says there is a removal (i.e., lies). There is a warning output along with the notice, however.

Each secrets file should contain only one key-value pair.

## Development

The project is held at github:
 
* [https://github.com/rjd1/puppet-kafka_connect](https://github.com/rjd1/puppet-kafka_connect)
 
Issue reports, patches, pull requests are welcome!
