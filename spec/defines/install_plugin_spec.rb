# frozen_string_literal: true

require 'spec_helper'

describe 'kafka_connect::install::plugin', type: :define do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { 'test/rspec-plugin:0.0.1' }
      # the required confluent-hub-client package is only included if the plugins list in the main class is not empty
      # need two separate plugins here to satisfy this, pass type validation, & avoid duplicate declaration errors
      let(:pre_condition) do
        <<-PUPPET
        class { 'kafka_connect':
          confluent_hub_plugins => [ 'author/plugin-name:latest' ],
        }
        PUPPET
      end

      it { is_expected.to compile.with_all_deps }

      describe 'with resource title plugin install' do
        it { is_expected.to contain_package('confluent-hub-client') }

        it {
          is_expected
            .to contain_exec('install_plugin_test-rspec-plugin')
            .with_command('confluent-hub install test/rspec-plugin:0.0.1 --no-prompt')
            .with_creates('/usr/share/confluent-hub-components/test-rspec-plugin')
            .with_path(['/bin', '/usr/bin', '/usr/local/bin'])
            .that_requires('Package[confluent-hub-client]')
            .that_notifies('Class[Kafka_connect::Service]')
        }
      end

      describe 'with author/plugin-name:latest plugin install' do
        it { is_expected.to contain_kafka_connect__install__plugin('author/plugin-name:latest') }

        it { is_expected.to contain_package('confluent-hub-client') }

        it {
          is_expected
            .to contain_exec('install_plugin_author-plugin-name')
            .with_command('confluent-hub install author/plugin-name:latest --no-prompt')
            .with_creates('/usr/share/confluent-hub-components/author-plugin-name')
            .with_path(['/bin', '/usr/bin', '/usr/local/bin'])
            .that_requires('Package[confluent-hub-client]')
            .that_notifies('Class[Kafka_connect::Service]')
        }
      end
    end
  end
end
