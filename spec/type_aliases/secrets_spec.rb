# frozen_string_literal: true

require 'spec_helper'

describe 'Kafka_connect::Secrets' do
  it { is_expected.to allow_value({ 'test-secret-file-rm.properties' => { 'ensure' => 'absent' } }) }

  it {
    is_expected
      .to allow_value(
        {
          'test-secret-file-1.properties' =>
          {
            'key'   => 'test-user',
            'value' => 'test-passwd',
          },
        },
      )
  }

  it {
    is_expected
      .to allow_value(
        {
          'test-secret-file-2.properties' =>
          {
            'key'        => 'test-secret',
            'value'      => 'test-value',
            'connectors' => [ 'connector1', 'connector2' ],
          },
        },
      )
  }
end
