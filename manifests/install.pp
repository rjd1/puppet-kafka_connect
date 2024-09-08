# @summary Main class for the Kafka Connect installation.
#
# @api private
#
class kafka_connect::install {
  assert_private()

  if $kafka_connect::install_source == 'package' {
    contain kafka_connect::install::package

    unless $kafka_connect::confluent_hub_plugins.empty {
      $kafka_connect::confluent_hub_plugins.each |$plugin| {
        kafka_connect::install::plugin { $plugin : }
      }
    }
  } else {
    contain kafka_connect::install::archive
  }
}
