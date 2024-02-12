# frozen_string_literal: true

require 'spec_helper'

describe 'kafka_connect' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }

      describe 'default' do
        it { is_expected.to contain_class 'kafka_connect' }
        it { is_expected.to contain_class 'kafka_connect::confluent_repo' }
        it { is_expected.to contain_class 'kafka_connect::install' }
        it { is_expected.to contain_class 'kafka_connect::config' }
        it { is_expected.to contain_class 'kafka_connect::service' }
        it { is_expected.to contain_class 'kafka_connect::manage_connectors' }

        it { is_expected.not_to contain_class 'java' }

        it { is_expected.to contain_exec('wait_30s_for_service_start') }

        it { is_expected.to contain_file('/etc/kafka-connect') }
        it { is_expected.to contain_file('/etc/kafka/connect-distributed.properties') }
        it { is_expected.to contain_file('/etc/kafka/connect-log4j.properties') }
        it { is_expected.to contain_file('/usr/bin/connect-distributed') }

        it { is_expected.to contain_package('confluent-kafka') }
        it { is_expected.to contain_package('confluent-common') }
        it { is_expected.to contain_package('confluent-rest-utils') }
        it { is_expected.to contain_package('confluent-schema-registry') }

        it { is_expected.not_to contain_package('confluent-hub-client') }

        it { is_expected.to contain_service('confluent-kafka-connect') }

        case os_facts[:osfamily]
        when 'RedHat'
          it { is_expected.to contain_yumrepo('confluent') }
        when 'Debian'
          it { is_expected.to contain_apt__source('confluent') }
        else
          it { is_expected.to compile.and_raise_error(/Confluent repository is not supported on/) }
        end
      end

      describe 'with connector management only' do
        let(:params) { { manage_connectors_only: true } }

        it { is_expected.to contain_class 'kafka_connect::manage_connectors' }

        it { is_expected.not_to contain_class 'kafka_connect::config' }
        it { is_expected.not_to contain_class 'kafka_connect::confluent_repo' }
        it { is_expected.not_to contain_class 'kafka_connect::install' }
        it { is_expected.not_to contain_class 'kafka_connect::service' }
      end

      describe 'with java' do
        let(:params) { { include_java: true } }

        it { is_expected.to contain_class 'java' }
      end

      describe 'without managed repo' do
        let(:params) { { manage_confluent_repo: false } }

        it { is_expected.to_not contain_class 'kafka_connect::confluent_repo'  }
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
        let :params do {
          :manage_schema_registry_package => false,
          :confluent_hub_plugins => [],
        }
        end

        it { is_expected.not_to contain_package('confluent-common') }
        it { is_expected.not_to contain_package('confluent-rest-utils') }
        it { is_expected.not_to contain_package('confluent-schema-registry') }
        it { is_expected.not_to contain_package('confluent-hub-client') }
      end

      describe 'with service_name set to valid value' do
        let(:params) { { service_name: 'testing-svc-name' } }

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

      describe 'with plugin install' do
        let(:params) { { confluent_hub_plugins: ['acme/fancy-plugin:0.1.0'] } }

        it { is_expected.to contain_package('confluent-common') }
        it { is_expected.to contain_package('confluent-hub-client') }

        it { is_expected.to contain_exec('install_plugin_acme-fancy-plugin')
          .with_command('confluent-hub install acme/fancy-plugin:0.1.0 --no-prompt')
          .with_creates('/usr/share/confluent-hub-components/acme-fancy-plugin')
          .with_path(['/bin','/usr/bin','/usr/local/bin'])
        }
      end
    end
  end
end
