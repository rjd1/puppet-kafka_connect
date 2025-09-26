# @summary Manages individual Kafka Connect connector secrets.
#
# KC connector secret class.
#
# @param secrets_data
#   Hash of secret file names and their corresponding data.
#
# @api private
#
class kafka_connect::manage_connectors::secret (
  Kafka_connect::Secrets $secrets_data,
) {
  assert_private()

  $secrets_data.each |$secret| {
    $secret_file_name  = $secret[0]
    $secret_ensure     = $secret[1]['ensure']
    $secret_connectors = $secret[1]['connectors']
    $secret_key        = $secret[1]['key']
    $secret_value      = $secret[1]['value']
    $secret_kv_data    = $secret[1]['kv_data']

    if $secret_ensure {
      $secret_file_ensure = $secret_ensure
    } else {
      $secret_file_ensure = 'present'
    }

    if $secret_file_ensure == 'absent' {
      $secret_content = undef
      $secret_notify  = undef
    } elsif !$secret_connectors {
      $secret_notify  = undef
    } else {
      $secret_notify  = Kc_connector[$secret_connectors]
    }

    if $secret_file_ensure =~ /^(present|file)$/ {
      unless (($secret_key and $secret_value) or $secret_kv_data) and !(($secret_key or $secret_value) and $secret_kv_data) {
        fail("Either secret key and value or kv_data is required, unless ensure is set to absent. \
          \n Validation error on ${secret_file_name} data, please correct. \n")
      }

      if $secret_kv_data {
        $_secret_kv_data = join($secret_kv_data.map |$key,$value| { "${key}=${value}" }, "\n")
        $secret_data     = "${_secret_kv_data}\n"
      } else {
        $secret_data     = "${secret_key}=${secret_value}\n"
      }

      unless $kafka_connect::disable_node_encrypt {
        if (extlib::has_module('puppetlabs/node_encrypt') or extlib::has_module('binford2k/node_encrypt')) {
          $secret_content = Sensitive($secret_data).node_encrypt::secret
        } else {
          $secret_content = Sensitive($secret_data)
        }
      } else {
        $secret_content = Sensitive($secret_data)
      }
    }

    if $kafka_connect::owner {
      $_owner = $kafka_connect::owner
    } else {
      $_owner = $kafka_connect::user
    }

    file { $secret_file_name :
      ensure    => $secret_file_ensure,
      path      => "${kafka_connect::connector_config_dir}/${secret_file_name}",
      content   => $secret_content,
      owner     => $_owner,
      group     => $kafka_connect::group,
      mode      => $kafka_connect::connector_secret_file_mode,
      show_diff => false,
      notify    => $secret_notify,
    }
  }
}
