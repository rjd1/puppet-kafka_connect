# @summary Manages the Confluent package repository.
#
# KC Confluent repo class.
#
# @api private
#
class kafka_connect::confluent_repo {
  assert_private()

  case $facts['os']['family'] {
    'RedHat': {
      contain kafka_connect::confluent_repo::yum
    }
    'Debian': {
      contain kafka_connect::confluent_repo::apt
    }
    default: {
      fail(sprintf('Confluent repository is not supported on %s', $facts['os']['family']))
    }
  }
}
