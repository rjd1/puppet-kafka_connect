# frozen_string_literal: true

require 'spec_helper'

describe 'Kafka_connect::Connectors' do
  it {
    is_expected
      .not_to allow_value(
        {
          'test-connector-file-rm.properties' =>
          {
            'ensure' => 'absent',
          },
        },
      )
  }

  it {
    is_expected
      .to allow_value(
        {
          'test-connector-file-rm.properties' =>
          {
            'name'   => 'test-connector-rm',
            'ensure' => 'absent',
          },
        },
      )
  }

  it {
    is_expected
      .to allow_value(
        {
          'test-connector-file-1.properties' =>
          {
            'name'   => 'test-connector1',
            'ensure' => 'paused',
          },
        },
      )
  }

  it {
    is_expected
      .to allow_value(
        {
          'test-connector-file-2.properties' =>
          {
            'name'   => 'test-connector2',
            'config' =>
            {
              'config1' => 'string1',
              'config2' => 'string2',
            },
          },
        },
      )
  }
end
