# frozen_string_literal: true

require 'spec_helper'

describe 'Kafka_connect::Loglevel' do
  describe 'valid loglevels' do
    [
      'TRACE',
      'DEBUG',
      'INFO',
      'WARN',
      'ERROR',
      'FATAL',
    ].each do |value|
      describe value.inspect do
        it { is_expected.to allow_value(value) }
      end
    end
  end

  describe 'invalid loglevels' do
    [
      [nil],
      [nil, nil],
      { 'foo' => 'bar' },
      {},
      '',
      "\nWARN",
      "\nWARN\n",
      "WARN\n",
      'warn',
      'warning',
      'CRITICAL',
      'important',
    ].each do |value|
      describe value.inspect do
        it { is_expected.not_to allow_value(value) }
      end
    end
  end
end
