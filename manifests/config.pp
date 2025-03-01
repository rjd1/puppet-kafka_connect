# @summary Manages the Kafka Connect configuration.
#
# KC config class.
#
# @api private
#
class kafka_connect::config {
  assert_private()

  $kafka_servers = join( $kafka_connect::bootstrap_servers, ',')

  if $kafka_connect::install_source == 'package' {
    $bin_dir           = '/usr/bin'
    $bin_file_suffix   = ''
    $service_prefix    = 'confluent-'
    $sysd_doc_link     = 'http://docs.confluent.io/'
    $zk_and_kafka_user = 'cp-kafka'

    $file_ensure = $kafka_connect::package_ensure ? {
      /^(absent|purged)$/ => 'absent',
      default             => 'present',
    }
  } else {
    $file_ensure       = 'present'
    $bin_dir           = "${kafka_connect::archive_install_dir}/bin"
    $bin_file_suffix   = '.sh'
    $service_prefix    = ''
    $sysd_doc_link     = 'https://kafka.apache.org/documentation/'
    $zk_and_kafka_user = $kafka_connect::user

    if $kafka_connect::kc_config_dir != "${kafka_connect::archive_install_dir}/config" {
      file { $kafka_connect::kc_config_dir :
        ensure => 'link',
        target => "${kafka_connect::archive_install_dir}/config",
        before => File[
          "${kafka_connect::kc_config_dir}/connect-${kafka_connect::config_mode}.properties",
          "${kafka_connect::kc_config_dir}/connect-log4j.properties",
        ],
      }
    }
  }

  if $kafka_connect::config_mode == 'distributed' {
    file { "${bin_dir}/connect-distributed${bin_file_suffix}" :
      ensure  => $file_ensure,
      content => template("kafka_connect/connect-distributed${bin_file_suffix}.erb"),
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
    }
  }

  if $kafka_connect::owner {
    $_owner = $kafka_connect::owner
  } else {
    $_owner = $kafka_connect::user
  }

  file { "${kafka_connect::kc_config_dir}/connect-${kafka_connect::config_mode}.properties":
    ensure  => $file_ensure,
    content => template("kafka_connect/connect-${kafka_connect::config_mode}.properties.erb"),
    owner   => $_owner,
    group   => $kafka_connect::group,
    mode    => '0640',
  }

  file { "${kafka_connect::kc_config_dir}/connect-log4j.properties":
    ensure  => $file_ensure,
    content => template('kafka_connect/connect-log4j.properties.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  if $kafka_connect::manage_systemd_service_file {
    file { "/usr/lib/systemd/system/${kafka_connect::service_name}.service" :
      ensure  => $file_ensure,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('kafka_connect/systemd/kafka-connect.service.erb'),
    }

    if $kafka_connect::run_local_kafka_broker_and_zk {
      file { "/usr/lib/systemd/system/${service_prefix}kafka.service" :
        ensure  => $file_ensure,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('kafka_connect/systemd/kafka.service.erb'),
      }

      file { "/usr/lib/systemd/system/${service_prefix}zookeeper.service" :
        ensure  => $file_ensure,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('kafka_connect/systemd/zookeeper.service.erb'),
      }
    }
  }
}
