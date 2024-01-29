# @summary Manages the Kafka Connect installation.
#
# @api private
#
class kafka_connect::install {

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
    package { [ $kafka_connect::confluent_rest_utils_package_name, $kafka_connect::schema_registry_package_name ] :
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

  $kafka_connect::confluent_hub_plugins.each |$plugin| {
    unless $plugin =~ /^\w+\/[a-zA-z0-9]{1,}[a-zA-z0-9\-]{0,}:\d+\.\d+\.\d+$/ {
      fail("Unexpected plugin value encountered: ${plugin} \
        \n This should be in the format author/name:semantic-version, e.g. acme/fancy-plugin:0.1.0 \n")
    }

    $author = regsubst($plugin,'^(\w+)\/.+:.+$','\1')
    $name   = regsubst($plugin,'^(\w+)\/([a-zA-z0-9]{1,}[a-zA-z0-9\-]{0,}):.+$','\2')

    exec { "install_plugin_${author}-${name}":
      command => "confluent-hub install ${plugin} --no-prompt",
      creates => "${kafka_connect::confluent_hub_plugin_path}/${author}-${name}",
      path    => ['/bin','/sbin','/usr/bin','/usr/sbin','/usr/local/bin'],
      require => Package[$kafka_connect::package_name,$kafka_connect::confluent_hub_client_package_name],
      notify  => Class['kafka_connect::service'],
    }
  }

}
