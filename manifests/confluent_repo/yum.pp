# @summary Manages the Confluent yum package repository.
#
# KC Confluent yum repo class.
#
# @api private
#
class kafka_connect::confluent_repo::yum {
  assert_private()

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

  exec { 'kc_flush-yum-cache':
    command     => 'yum clean metadata expire-cache --disablerepo="*" --enablerepo="confluent"',
    refreshonly => true,
    path        => ['/bin','/usr/bin','/sbin','/usr/sbin'],
  }

  Yumrepo['confluent'] ~> Exec['kc_flush-yum-cache'] -> Package[$kafka_connect::package_name]
}
