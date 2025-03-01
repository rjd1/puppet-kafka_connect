# @summary Manages the Kafka Connect package installation.
#
# KC package install class.
#
# @api private
#
class kafka_connect::install::package {
  assert_private()

  package { $kafka_connect::package_name :
    ensure => $kafka_connect::package_ensure,
  }

  # Install 'common' package first, if needed, to avoid any potential dependency version conflicts.
  if ($kafka_connect::manage_schema_registry_package or !$kafka_connect::confluent_hub_plugins.empty) {
    package { $kafka_connect::confluent_common_package_name :
      ensure => $kafka_connect::package_ensure,
    }
  }

  if $kafka_connect::manage_schema_registry_package {
    package { [$kafka_connect::confluent_rest_utils_package_name, $kafka_connect::schema_registry_package_name]:
      ensure  => $kafka_connect::package_ensure,
      require => Package[$kafka_connect::confluent_common_package_name],
    }
  }

  if !$kafka_connect::confluent_hub_plugins.empty {
    package { $kafka_connect::confluent_hub_client_package_name :
      ensure  => $kafka_connect::package_ensure,
      require => Package[$kafka_connect::confluent_common_package_name],
    }
  }
}
