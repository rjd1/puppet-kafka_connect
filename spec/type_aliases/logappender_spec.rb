# frozen_string_literal: true

require 'spec_helper'

describe 'Kafka_connect::LogAppender' do
  describe 'valid log appenders' do
    [
      'DailyRollingFileAppender',
      'RollingFileAppender',
    ].each do |value|
      describe value.inspect do
        it { is_expected.to allow_value(value) }
      end
    end
  end

  describe 'invalid log appenders' do
    [
      [nil],
      [nil, nil],
      { 'foo' => 'bar' },
      {},
      '',
      "\nDailyRollingFileAppender",
      "\nDailyRollingFileAppender\n",
      "HourlyRollingFileAppender\n",
      'WeeklyRollingFileAppender',
      'SomeRollingFileAppender',
      'FancyFileAppender',
      'AcmeAppender',
    ].each do |value|
      describe value.inspect do
        it { is_expected.not_to allow_value(value) }
      end
    end
  end
end
