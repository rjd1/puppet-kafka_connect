# Manages the Confluent package repository.
#
# @api private
#
class kafka_connect::confluent_repo {
  assert_private()

  if $facts['os']['family'] == 'RedHat' {
    yumrepo { 'confluent':
      ensure              => $kafka_connect::repo_ensure,
      baseurl             => "http://packages.confluent.io/rpm/${kafka_connect::repo_version}",
      name                => 'confluent',
      descr               => 'Confluent repository',
      enabled             => $kafka_connect::repo_enabled,
      gpgcheck            => '1',
      gpgkey              => "http://packages.confluent.io/rpm/${kafka_connect::repo_version}/archive.key",
      skip_if_unavailable => '1',
    }

  } elsif $facts['os']['family'] == 'Debian' {
    apt::source { 'confluent':
      ensure   => $kafka_connect::repo_ensure,
      comment  => 'Confluent repository',
      location => "https://packages.confluent.io/deb/${kafka_connect::repo_version}",
      release  => 'stable',
      repos    => 'main',
      key      => {
        id     => 'CBBB821E8FAF364F79835C438B1DA6120C2BF624',
        source => "https://packages.confluent.io/deb/${kafka_connect::repo_version}/archive.key"
      },
    }

    Apt::Source['confluent'] -> Class['apt::update'] -> Class[$kafk_connect::install]

  } else {
    fail(sprintf('Confluent repository is not supported on %s', $facts['os']['family']))
  }

}
