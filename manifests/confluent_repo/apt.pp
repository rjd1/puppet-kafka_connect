# @summary Manages the Confluent apt package repository.
#
# KC Confluent apt repo class.
#
# @api private
#
class kafka_connect::confluent_repo::apt {
  assert_private()

  include apt

  apt::source { 'confluent':
    ensure   => $kafka_connect::repo_ensure,
    comment  => 'Confluent repository',
    location => "https://packages.confluent.io/deb/${kafka_connect::repo_version}",
    release  => 'stable',
    repos    => 'main',
    key      => {
      id     => 'CBBB821E8FAF364F79835C438B1DA6120C2BF624',
      source => "https://packages.confluent.io/deb/${kafka_connect::repo_version}/archive.key",
    },
  }

  Apt::Source['confluent'] -> Class['apt::update'] -> Package[$kafka_connect::package_name]
}
