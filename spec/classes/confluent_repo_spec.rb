# frozen_string_literal: true

require 'spec_helper'

describe 'kafka_connect::confluent_repo' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:hiera_config) { 'hiera-rspec.yaml' }
      let(:pre_condition) { 'include kafka_connect' }

      it { is_expected.to compile.with_all_deps }

      case facts[:os]['family']
      when 'RedHat'
        it { is_expected.to contain_class('kafka_connect::confluent_repo::yum') }
        it {
          is_expected.to contain_yumrepo('confluent').with(
            baseurl: 'http://packages.confluent.io/rpm/7.5',
            enabled: true,
            gpgcheck: 1,
            gpgkey: 'http://packages.confluent.io/rpm/7.5/archive.key',
            skip_if_unavailable: 1,
          ).that_notifies('Exec[kc_flush-yum-cache]')
        }
        it {
          is_expected.to contain_exec('kc_flush-yum-cache')
            .with_command('yum clean all')
            .with_refreshonly(true)
            .with_path(['/bin', '/usr/bin', '/sbin', '/usr/sbin'])
            .that_comes_before('Package[confluent-kafka]')
        }
      when 'Debian'
        it { is_expected.to contain_class('kafka_connect::confluent_repo::apt') }
        it { is_expected.to contain_class('apt') }
        it {
          is_expected.to contain_apt__source('confluent').with(
            location: 'https://packages.confluent.io/deb/7.5',
            release: 'stable',
            repos: 'main',
            key: {
              'id' => 'CBBB821E8FAF364F79835C438B1DA6120C2BF624',
              'source' => 'https://packages.confluent.io/deb/7.5/archive.key',
            },
          ).that_comes_before('Class[apt::update]')
        }
        it {
          is_expected.to contain_class('apt::update')
            .that_comes_before('Package[confluent-kafka]')
        }
      end
    end
  end

  context 'on unsupported os' do
    let(:facts) { { os: { family: 'SCO' } } }
    let(:pre_condition) { 'include kafka_connect' }

    it { is_expected.to compile.and_raise_error(%r{Confluent\srepository\sis\snot\ssupported\son\sSCO}) }
  end
end
