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

        it { is_expected.to contain_package 'confluent-kafka' }
        it { is_expected.to contain_package 'confluent-common' }
        it { is_expected.to contain_package 'confluent-rest-utils' }
        it { is_expected.to contain_package 'confluent-schema-registry' }

        it { is_expected.to contain_service 'confluent-kafka-connect' }

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

        it { is_expected.to_not contain_class('kafka_connect::manage_confluent_repo') }
      end

      describe 'without schema reg package' do
        let(:params) { { manage_schema_registry_package: false } }

        it { is_expected.not_to contain_package('confluent-schema-registry') }
      end
    end
  end
end
