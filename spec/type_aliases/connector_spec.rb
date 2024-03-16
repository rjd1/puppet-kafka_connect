# frozen_string_literal: true

require 'spec_helper'

describe 'Kafka_connect::Connector' do
  it {
    is_expected
      .to allow_value(
        {
          'ensure' => 'absent',
          'name'   => 'test-connector',
        },
      )
  }

  it {
    is_expected
      .to allow_value(
        {
          'ensure' => 'present',
          'name'   => 'test-connector',
          'config' => { 'key-one' => 'value-one', 'key-two' => 'value-two', },
        },
      )
  }
end
