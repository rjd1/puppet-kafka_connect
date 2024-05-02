# frozen_string_literal: true

require 'spec_helper'

describe 'kafka_connect::manage_connectors' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:pre_condition) { 'include kafka_connect' }

      it { is_expected.to compile.with_all_deps }

      describe 'default, with connector and secret data' do
        let(:hiera_config) { 'hiera-rspec.yaml' }

        it { is_expected.to contain_class('kafka_connect::manage_connectors::connector') }
        it { is_expected.to contain_class('kafka_connect::manage_connectors::secret') }
      end

      describe 'default, with no connector or secret data' do
        it { is_expected.not_to contain_class('kafka_connect::manage_connectors::connector') }
        it { is_expected.not_to contain_class('kafka_connect::manage_connectors::secret') }
      end
    end
  end
end
