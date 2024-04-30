# frozen_string_literal: true

require 'spec_helper'

describe 'kafka_connect::confluent_repo' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:pre_condition) { 'include kafka_connect' }

      it { is_expected.to compile.with_all_deps }

      case facts[:os]['family']
      when 'RedHat'
        it { is_expected.to contain_class('kafka_connect::confluent_repo::yum') }
        it { is_expected.to contain_yumrepo('confluent') }
        it { is_expected.to contain_exec('flush_yum_cache') }
      when 'Debian'
        it { is_expected.to contain_class('kafka_connect::confluent_repo::apt') }
        it { is_expected.to contain_apt__source('confluent') }
      end
    end
  end

  context 'on unsupported os' do
    let(:facts) { { os: { family: 'SCO' } } }
    let(:pre_condition) { 'include kafka_connect' }

    it { is_expected.to compile.and_raise_error(%r{Confluent\srepository\sis\snot\ssupported\son\sSCO}) }
  end
end
