# Manages the Confluent Package Repository.
#
# @api private
#
class kafka_connect::confluent_repo {
  assert_private()

  yumrepo { 'confluent':
    ensure              => $kafka_connect::repo_ensure,
    baseurl             => "http://packages.confluent.io/rpm/${kafka_connect::repo_version}",
    name                => 'Confluent',
    descr               => 'Confluent repository',
    enabled             => $kafka_connect::repo_enabled,
    gpgcheck            => '1',
    gpgkey              => "http://packages.confluent.io/rpm/${kafka_connect::repo_version}/archive.key",
    skip_if_unavailable => '1',
  }

}
