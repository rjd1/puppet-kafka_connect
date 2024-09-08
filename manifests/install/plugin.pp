# @summary Defined type for Confluent plugin installations.
#
# @param plugin
#  Name of plugin to install.
#
define kafka_connect::install::plugin (
  String[1] $plugin = $title,
) {
  $author = regsubst($plugin,'^(\w+)\/.+:.+$','\1')
  $name   = regsubst($plugin,'^(\w+)\/([a-zA-z0-9]{1,}[a-zA-z0-9\-]{0,}):.+$','\2')

  exec { "install_plugin_${author}-${name}":
    command => "confluent-hub install ${plugin} --no-prompt",
    creates => "${kafka_connect::confluent_hub_plugin_path}/${author}-${name}",
    path    => ['/bin','/usr/bin','/usr/local/bin'],
    require => Package[$kafka_connect::package_name,$kafka_connect::confluent_hub_client_package_name],
    notify  => Class['kafka_connect::service'],
  }
}
