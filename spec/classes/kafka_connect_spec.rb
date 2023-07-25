# frozen_string_literal: true

require 'spec_helper'

describe 'kafka_connect' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      it { is_expected.to compile }
    end
  end
end
