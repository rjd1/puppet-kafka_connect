# frozen_string_literal: true

require 'spec_helper'

describe 'kafka_connect' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:hiera_config) { 'hiera-rspec.yaml' }

      it { is_expected.to compile.with_all_deps }

      describe 'default' do
        it { is_expected.to contain_class('kafka_connect') }
        it { is_expected.to contain_class('kafka_connect::confluent_repo').that_comes_before('Class[kafka_connect::install]') }
        it {
          is_expected
            .to contain_class('kafka_connect::config')
            .that_requires(['Class[kafka_connect::install]'])
            .that_notifies(['Class[kafka_connect::service]'])
        }
        it { is_expected.to contain_class('kafka_connect::install') }
        it { is_expected.to contain_class('kafka_connect::service').that_comes_before('Class[kafka_connect::manage_connectors]') }
        it { is_expected.to contain_class('kafka_connect::manage_connectors') }

        it { is_expected.not_to contain_class('kafka_connect::user') }
        it { is_expected.not_to contain_class('java') }

        it { is_expected.to contain_file('/etc/kafka-connect').with_ensure('directory') }
        it {
          is_expected
            .to contain_file('/etc/kafka/connect-distributed.properties')
            .with_ensure('present')
            .with_owner('cp-kafka-connect')
            .with_group('confluent')
            .with_mode('0640')
            .with_content(%r{^bootstrap\.servers=localhost:9092$})
            .with_content(%r{^group\.id=connect-cluster$})
            .with_content(%r{^key\.converter=org\.apache\.kafka\.connect\.json\.JsonConverter$})
            .with_content(%r{^value\.converter=org\.apache\.kafka\.connect\.json\.JsonConverter$})
            .with_content(%r{^key\.converter\.schemas\.enable=true$})
            .with_content(%r{^value\.converter\.schemas\.enable=true$})
            .with_content(%r{^offset\.storage\.topic=connect-offsets$})
            .with_content(%r{^offset\.storage\.replication\.factor=1$})
            .with_content(%r{^offset\.storage\.partitions=25$})
            .with_content(%r{^config\.storage\.topic=connect-configs$})
            .with_content(%r{^config\.storage\.replication\.factor=1$})
            .with_content(%r{^status\.storage\.topic=connect-status$})
            .with_content(%r{^status\.storage\.replication\.factor=1$})
            .with_content(%r{^status\.storage\.partitions=5$})
            .with_content(%r{^offset\.flush.interval\.ms=10000$})
            .with_content(%r{^listeners=HTTP://:8083$})
            .with_content(%r{^plugin\.path=/usr/share/java,/usr/share/confluent-hub-components$})
        }
        it {
          is_expected
            .to contain_file('/etc/kafka/connect-log4j.properties')
            .with_ensure('present')
            .with_owner('root')
            .with_group('root')
            .with_mode('0644')
            .with_content(%r{^log4j\.rootLogger=INFO, file$})
            .with_content(%r{^log4j\.appender\.file=org\.apache\.log4j\.RollingFileAppender$})
            .with_content(%r{^log4j\.appender\.file\.layout=org\.apache\.log4j\.PatternLayout$})
            .with_content(%r{^log4j\.appender\.file\.File=/var/log/confluent/connect\.log$})
            .with_content(%r{^log4j\.appender\.file\.MaxFileSize=100MB$})
            .with_content(%r{^log4j\.appender\.file\.MaxBackupIndex=10$})
        }
        it {
          is_expected
            .to contain_file('/usr/lib/systemd/system/confluent-kafka-connect.service')
            .with_ensure('present')
            .with_owner('root')
            .with_group('root')
            .with_mode('0644')
            .with_content(%r{^Description=Apache Kafka Connect - distributed$})
            .with_content(%r{^User=cp-kafka-connect$})
            .with_content(%r{^Group=confluent$})
            .with_content(%r{^ExecStart=/usr/bin/connect-distributed /etc/kafka/connect-distributed\.properties$})
        }
        it { is_expected.to contain_file('/usr/bin/connect-distributed').with_content(%r{export KAFKA_HEAP_OPTS="-Xms256M -Xmx2G"$}) }

        it { is_expected.to contain_package('confluent-kafka').with_ensure('7.5.0-1') }
        it { is_expected.to contain_package('confluent-common').with_ensure('7.5.0-1') }
        it { is_expected.to contain_package('confluent-rest-utils').with_ensure('7.5.0-1') }
        it { is_expected.to contain_package('confluent-schema-registry').with_ensure('7.5.0-1') }

        it { is_expected.to contain_service('confluent-kafka-connect') }

        it {
          is_expected
            .to contain_exec('wait_30s_for_service_start')
            .with_command('sleep 30')
            .with_refreshonly(true)
            .with_path(['/bin', '/usr/bin', '/usr/local/bin'])
            .that_subscribes_to('Service[confluent-kafka-connect]')
        }

        it { is_expected.not_to contain_package('confluent-hub-client') }
      end

      describe 'with connector management only' do
        let(:params) { { manage_connectors_only: true } }

        it { is_expected.to contain_class('kafka_connect::manage_connectors') }

        it { is_expected.not_to contain_class('kafka_connect::config') }
        it { is_expected.not_to contain_class('kafka_connect::confluent_repo') }
        it { is_expected.not_to contain_class('kafka_connect::install') }
        it { is_expected.not_to contain_class('kafka_connect::service') }
      end

      describe 'with standalone mode and local kafka & zk services' do
        let(:params) { { config_mode: 'standalone', run_local_kafka_broker_and_zk: true } }

        it {
          is_expected
            .to contain_file('/etc/kafka/connect-standalone.properties')
            .with_ensure('present')
            .with_owner('cp-kafka-connect')
            .with_group('confluent')
            .with_mode('0640')
            .with_content(%r{^bootstrap\.servers=localhost:9092$})
            .with_content(%r{^key\.converter=org\.apache\.kafka\.connect\.json\.JsonConverter$})
            .with_content(%r{^value\.converter=org\.apache\.kafka\.connect\.json\.JsonConverter$})
            .with_content(%r{^key\.converter\.schemas\.enable=true$})
            .with_content(%r{^value\.converter\.schemas\.enable=true$})
            .with_content(%r{^offset\.storage\.file\.filename=/tmp/connect\.offsets$})
            .with_content(%r{^offset\.flush.interval\.ms=10000$})
            .with_content(%r{^plugin\.path=/usr/share/java,/usr/share/confluent-hub-components$})
        }
        it {
          is_expected
            .to contain_file('/usr/lib/systemd/system/confluent-kafka-connect.service')
            .with_content(%r{^Description=Apache Kafka Connect - standalone$})
        }
        it {
          is_expected
            .to contain_file('/usr/lib/systemd/system/confluent-kafka.service')
            .with_ensure('present')
            .with_owner('root')
            .with_group('root')
            .with_mode('0644')
            .with_content(%r{^Description=Apache Kafka - broker$})
            .with_content(%r{^User=cp-kafka$})
            .with_content(%r{^Group=confluent$})
            .with_content(%r{^ExecStart=/usr/bin/kafka-server-start /etc/kafka/server\.properties$})
        }
        it {
          is_expected
            .to contain_file('/usr/lib/systemd/system/confluent-zookeeper.service')
            .with_ensure('present')
            .with_owner('root')
            .with_group('root')
            .with_mode('0644')
            .with_content(%r{^Description=Apache Kafka - ZooKeeper$})
            .with_content(%r{^User=cp-kafka$})
            .with_content(%r{^Group=confluent$})
            .with_content(%r{^ExecStart=/usr/bin/zookeeper-server-start /etc/kafka/zookeeper\.properties$})
        }
        it { is_expected.to contain_service('confluent-kafka') }
        it { is_expected.to contain_service('confluent-zookeeper') }

        it { is_expected.not_to contain_file('/etc/kafka/connect-distributed.properties') }
        it { is_expected.not_to contain_file('/usr/bin/connect-distributed') }
      end

      describe 'with java' do
        let(:params) { { include_java: true } }

        it { is_expected.to contain_class 'java' }
      end

      describe 'without managed repo' do
        let(:params) { { manage_confluent_repo: false } }

        it { is_expected.not_to contain_class 'kafka_connect::confluent_repo' }
      end

      describe 'with kafka_jvm_performance_options config' do
        let(:params) { { kafka_jvm_performance_options: '-server -XX:+UseG1GC -XX:MaxGCPauseMillis=100 -XX:InitiatingHeapOccupancyPercent=50 -XX:+ExplicitGCInvokesConcurrent -XX:MaxInlineLevel=15 -Djava.awt.headless=true' } } # rubocop:disable Layout/LineLength

        it { is_expected.to contain_file('/usr/bin/connect-distributed').with_content(%r{^export KAFKA_JVM_PERFORMANCE_OPTS="-server -XX:\+UseG1GC -XX:MaxGCPauseMillis=100 -XX:InitiatingHeapOccupancyPercent=50 -XX:\+ExplicitGCInvokesConcurrent -XX:MaxInlineLevel=15 -Djava.awt.headless=true"$}) } # rubocop:disable Layout/LineLength
      end

      describe 'with owner set to valid string value' do
        let(:params) { { owner: 'test-owner' } }

        it { is_expected.to contain_file('/etc/kafka/connect-distributed.properties').with_owner('test-owner') }
      end

      describe 'with owner set to valid integer value' do
        let(:params) { { owner: 555 } }

        it { is_expected.to contain_file('/etc/kafka/connect-distributed.properties').with_owner(555) }
      end

      describe 'with group set to valid string value' do
        let(:params) { { group: 'test-group' } }

        it { is_expected.to contain_file('/etc/kafka/connect-distributed.properties').with_group('test-group') }
      end

      describe 'with group set to valid integer value' do
        let(:params) { { group: 555 } }

        it { is_expected.to contain_file('/etc/kafka/connect-distributed.properties').with_group(555) }
      end

      describe 'with package_name set to valid value' do
        let(:params) { { package_name: 'testing-pkg-name' } }

        it { is_expected.to contain_package('testing-pkg-name') }
      end

      describe 'with package_ensure set to custom version' do
        let(:params) { { package_ensure: '8.0.0' } }

        it { is_expected.to contain_package('confluent-kafka').with_ensure('8.0.0') }
      end

      describe 'with package_ensure absent' do
        let(:params) { { package_ensure: 'absent' } }

        it { is_expected.to contain_package('confluent-kafka').with_ensure('absent') }
        it { is_expected.to contain_package('confluent-common').with_ensure('absent') }
        it { is_expected.to contain_package('confluent-rest-utils').with_ensure('absent') }
        it { is_expected.to contain_package('confluent-schema-registry').with_ensure('absent') }

        it { is_expected.to contain_file('/etc/kafka/connect-distributed.properties').with_ensure('absent') }
        it { is_expected.to contain_file('/etc/kafka/connect-log4j.properties').with_ensure('absent') }
        it { is_expected.to contain_file('/usr/bin/connect-distributed').with_ensure('absent') }

        it { is_expected.to contain_service('confluent-kafka-connect').with_ensure('stopped') }
      end

      describe 'without schema reg package' do
        let(:params) { { manage_schema_registry_package: false } }

        it { is_expected.not_to contain_package('confluent-rest-utils') }
        it { is_expected.not_to contain_package('confluent-schema-registry') }
      end

      describe 'without schema reg package or plugins' do
        let(:params) { { manage_schema_registry_package: false, confluent_hub_plugins: [] } }

        it { is_expected.not_to contain_package('confluent-common') }
        it { is_expected.not_to contain_package('confluent-rest-utils') }
        it { is_expected.not_to contain_package('confluent-schema-registry') }
        it { is_expected.not_to contain_package('confluent-hub-client') }
      end

      describe 'with service_name set to valid value' do
        let(:params) { { service_name: 'testing-svc-name' } }

        it { is_expected.to contain_file('/usr/lib/systemd/system/testing-svc-name.service') }

        it { is_expected.to contain_service('testing-svc-name') }
      end

      describe 'with service_enable false' do
        let(:params) { { service_enable: false } }

        it { is_expected.to contain_service('confluent-kafka-connect').with_enable(false) }
      end

      describe 'with service ensure stopped' do
        let(:params) { { service_ensure: 'stopped' } }

        it { is_expected.to contain_service('confluent-kafka-connect').with_ensure('stopped') }
      end

      describe 'with user and group managed' do
        let(:params) { { manage_user_and_group: true } }

        it { is_expected.to contain_class('kafka_connect::user').that_comes_before('Class[kafka_connect::install]') }

        it {
          is_expected.to contain_group('confluent')
            .with_ensure('present')
            .with_system(true)
        }

        it {
          is_expected.to contain_user('cp-kafka-connect')
            .with_ensure('present')
            .with_gid('confluent')
            .with_home('/var/empty')
            .with_shell('/sbin/nologin')
            .with_system(true)
            .that_requires('Group[confluent]')
        }
      end

      describe 'with user and group managed and absent' do
        let(:params) { { manage_user_and_group: true, user_and_group_ensure: 'absent' } }

        it { is_expected.to contain_class 'kafka_connect::user' }

        it { is_expected.to contain_group('confluent').with_ensure('absent') }

        it { is_expected.to contain_user('cp-kafka-connect').with_ensure('absent').that_requires('Group[confluent]') }
      end

      describe 'with alt user and group managed' do
        let(:params) { { manage_user_and_group: true, user: 'kafka', group: 'kafka' } }

        it { is_expected.to contain_class 'kafka_connect::user' }

        it {
          is_expected.to contain_group('kafka')
            .with_ensure('present')
            .with_system(true)
        }

        it {
          is_expected.to contain_user('kafka')
            .with_ensure('present')
            .with_gid('kafka')
            .with_home('/var/empty')
            .with_shell('/sbin/nologin')
            .with_system(true)
            .that_requires('Group[kafka]')
        }
      end

      describe 'with acme/fancy-plugin:0.1.0 plugin install' do
        let(:params) { { confluent_hub_plugins: ['acme/fancy-plugin:0.1.0'] } }

        it { is_expected.to contain_kafka_connect__install__plugin('acme/fancy-plugin:0.1.0') }

        it { is_expected.to contain_package('confluent-hub-client') }

        it {
          is_expected
            .to contain_exec('install_plugin_acme-fancy-plugin')
            .with_command('confluent-hub install acme/fancy-plugin:0.1.0 --no-prompt')
            .with_creates('/usr/share/confluent-hub-components/acme-fancy-plugin')
            .with_path(['/bin', '/usr/bin', '/usr/local/bin'])
            .that_requires('Package[confluent-hub-client]')
            .that_notifies('Class[Kafka_connect::Service]')
        }
      end

      describe 'with connector present' do
        it {
          is_expected
            .to contain_file('/etc/kafka-connect/connector-satu.json')
            .with_ensure('present')
            .with_owner('cp-kafka-connect')
            .with_group('confluent')
            .with_mode('0640')
            .with_content('{"name":"my-cool-connector","config":{"some.config.key":"value","some.other.config":"other_value","connection.password":"${file:/etc/kafka-connect/my-super-secret-file.properties:some-connection-passwd}"}}') # rubocop:disable Layout/LineLength
            .that_comes_before('Kc_connector[my-cool-connector]')
        }

        it {
          is_expected
            .to contain_kc_connector('my-cool-connector')
            .with_ensure('present')
            .with_config_file('/etc/kafka-connect/connector-satu.json')
            .with_enable_delete(false)
            .with_port(8083)
            .with_restart_on_failed_state(false)
        }
      end

      describe 'with connector absent' do
        let(:params) { { enable_delete: true } }

        it {
          is_expected
            .to contain_file('/etc/kafka-connect/connector-dua.json')
            .with_ensure('absent')
            .that_comes_before('Kc_connector[my-uncool-connector]')
        }

        it {
          is_expected
            .to contain_kc_connector('my-uncool-connector')
            .with_ensure('absent')
            .with_enable_delete(true)
        }
      end

      describe 'with connector paused' do
        it {
          is_expected
            .to contain_file('/etc/kafka-connect/connector-tiga.json')
            .with_ensure('present')
            .that_comes_before('Kc_connector[my-not-yet-cool-connector]')
        }

        it {
          is_expected
            .to contain_kc_connector('my-not-yet-cool-connector')
            .with_ensure('present')
            .with_connector_state_ensure('PAUSED')
        }
      end

      describe 'with connector data invalid (host1)' do
        let(:node) { 'host1.test.com' }

        it { is_expected.to compile.and_raise_error(%r{Connector config required}) }
      end

      describe 'with secret k/v string pair present' do
        it {
          is_expected
            .to contain_file('my-super-secret-file.properties')
            .with_ensure('present')
            .with_path('/etc/kafka-connect/my-super-secret-file.properties')
            .with_content(sensitive("some-connection-passwd=passwd-value\n"))
            .with_owner('cp-kafka-connect')
            .with_group('confluent')
            .with_mode('0600')
        }
      end

      describe 'with secret k/v hash data present' do
        it {
          is_expected
            .to contain_file('my-super-duper-secret-file.properties')
            .with_ensure('present')
            .with_path('/etc/kafka-connect/my-super-duper-secret-file.properties')
            .with_content(sensitive("db-url=my-db.example.com\ndb-user=some-user\ndb-passwd=some-passwd\n"))
            .with_owner('cp-kafka-connect')
            .with_group('confluent')
            .with_mode('0600')
        }
      end

      describe 'with secret absent' do
        it {
          is_expected
            .to contain_file('my-no-longer-a-secret-file.properties')
            .with_ensure('absent')
            .with_path('/etc/kafka-connect/my-no-longer-a-secret-file.properties')
        }
      end

      describe 'with secret data invalid (host2)' do
        let(:node) { 'host2.test.com' }

        it { is_expected.to compile.and_raise_error(%r{Validation error}) }
      end

      describe 'with secret data invalid (host3)' do
        let(:node) { 'host3.test.com' }

        it { is_expected.to compile.and_raise_error(%r{Validation error}) }
      end
    end
  end
end
