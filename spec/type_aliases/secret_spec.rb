# frozen_string_literal: true

require 'spec_helper'

describe 'Kafka_connect::Secret' do
  it { is_expected.to allow_value({ 'ensure' => 'absent' }) }

  it {
    is_expected
      .to allow_value(
        {
          'ensure' => 'file',
          'key'    => 'test-user',
          'value'  => 'test-passwd',
        },
      )
  }

  it {
    is_expected
      .to allow_value(
        {
          'ensure'     => 'present',
          'key'        => 'test-username',
          'value'      => 'test-password',
          'connectors' => [ 'connector-one', 'connector-two' ],
        },
      )
  }

  it {
    is_expected
      .to allow_value(
        {
          'key'        => 'test-key',
          'value'      => 'test-value',
          'connectors' => [ 'connector1', 'connector2' ],
        },
      )
  }
end
