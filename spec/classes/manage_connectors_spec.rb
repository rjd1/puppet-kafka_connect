# frozen_string_literal: true

require 'spec_helper'

describe 'kafka_connect::manage_connectors' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:pre_condition) { 'include kafka_connect' }
      it { is_expected.to compile }
    end
  end
end
