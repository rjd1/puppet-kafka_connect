# @summary Manages the Kafka Connect archive (.tgz) based installation.
#
# KC archive install class.
#
# @api private
#
class kafka_connect::install::archive {
  assert_private()

  $tgz_file = regsubst($kafka_connect::archive_source, '^http.*(kafka.*.tgz)$', '\1')

  if $kafka_connect::owner {
    $_owner = $kafka_connect::owner
  } else {
    $_owner = $kafka_connect::user
  }

  file { $kafka_connect::archive_install_dir :
    ensure => 'directory',
    owner  => $_owner,
    group  => $kafka_connect::group,
    mode   => '0755',
    before => Archive["/tmp/${tgz_file}"],
  }

  archive { "/tmp/${tgz_file}":
    ensure          => 'present',
    extract         => true,
    extract_command => 'tar xfz %s --strip-components=1',
    extract_path    => $kafka_connect::archive_install_dir,
    creates         => "${kafka_connect::archive_install_dir}/bin",
    cleanup         => true,
    user            => $_owner,
    group           => $kafka_connect::group,
    source          => $kafka_connect::archive_source,
  }
}
