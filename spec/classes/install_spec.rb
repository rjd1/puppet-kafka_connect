# frozen_string_literal: true

require 'spec_helper'

describe 'kafka_connect::install' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:pre_condition) { 'include kafka_connect' }

      it { is_expected.to compile.with_all_deps }

      describe 'with package install source' do
        it { is_expected.to contain_class 'kafka_connect::install::package' }

        it { is_expected.not_to contain_class 'kafka_connect::install::archive' }
      end

      describe 'with archive/tgz install source and standard setup' do
        let(:hiera_config) { 'hiera-rspec.yaml' }
        let(:node) { 'host4.test.com' }

        it { is_expected.to contain_class 'kafka_connect::install::archive' }

        it {
          is_expected
            .to contain_file('/etc/kafka')
            .with_ensure('link')
            .with_target('/opt/kafka/config')
        }

        it {
          is_expected
            .to contain_file('/opt/kafka')
            .with_ensure('directory')
            .with_owner('kafka')
            .with_group('kafka')
            .with_mode('0755')
            .that_comes_before('Archive[/tmp/kafka_2.13-3.7.0.tgz]')
        }

        it {
          is_expected
            .to contain_archive('/tmp/kafka_2.13-3.7.0.tgz')
            .with_ensure('present')
            .with_extract(true)
            .with_extract_path('/opt/kafka')
            .with_creates('/opt/kafka/bin')
            .with_cleanup(true)
            .with_user('kafka')
            .with_group('kafka')
            .with_source('https://downloads.apache.org/kafka/3.7.0/kafka_2.13-3.7.0.tgz')
        }

        it { is_expected.to contain_file('/opt/kafka/bin/connect-distributed.sh') }
        it {
          is_expected
            .to contain_file('/usr/lib/systemd/system/kafka-connect.service')
            .with_ensure('file')
            .with_owner('root')
            .with_group('root')
            .with_mode('0644')
            .with_content(%r{^User=kafka$})
            .with_content(%r{^Group=kafka$})
            .with_content(%r{^ExecStart=/opt/kafka/bin/connect-distributed\.sh /etc/kafka/connect-distributed\.properties$})
        }

        it { is_expected.to contain_service('kafka-connect') }

        it { is_expected.not_to contain_class 'kafka_connect::install::package' }
      end
    end
  end
end
