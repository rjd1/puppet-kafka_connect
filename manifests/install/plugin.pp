# @summary Defined type for Confluent Hub plugin installation.
#
# @param plugin
#  Plugin to install, in the form 'author/name:(semantic-version|latest)'.
#
define kafka_connect::install::plugin (
  Kafka_connect::HubPlugin $plugin = $title,
) {
  $plugin_author = regsubst($plugin, '^(\w+)\/.+:.+$', '\1')
  $plugin_name   = regsubst($plugin, '^(\w+)\/([a-zA-z0-9]{1,}[a-zA-z0-9\-]{0,}):.+$', '\2')

  exec { "install_plugin_${plugin_author}-${plugin_name}":
    command => "confluent-hub install ${plugin} --no-prompt",
    creates => "${kafka_connect::confluent_hub_plugin_path}/${plugin_author}-${plugin_name}",
    path    => ['/bin','/usr/bin','/usr/local/bin'],
    require => Package[$kafka_connect::confluent_hub_client_package_name],
    notify  => Class['kafka_connect::service'],
  }
}
