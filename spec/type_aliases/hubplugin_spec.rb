# frozen_string_literal: true

require 'spec_helper'

describe 'Kafka_connect::HubPlugin' do
  describe 'valid hub plugin' do
    [
      'acme/fancy-plugin:0.1.0',
      'acme/fancier-plugin:latest',
      'confluentinc/kafka-connect-jdbc:10.7.4',
      'perusahaan/experimental-kafka-connect-plugin:0.0.1',
    ].each do |value|
      describe value.inspect do
        it { is_expected.to allow_value(value) }
      end
    end
  end

  describe 'invalid hub plugin' do
    [
      nil,
      [nil],
      { 'foo' => 'bar' },
      {},
      '',
      [ 'acme/fancy-plugin:0.1.0' ],
      'acme/fancy-plugin',
      'acme/fancy-plugin:0.1.0-1',
      'fancy-plugin',
      'fancy-plugin:0.1.0',
      'fancy-plugin:latest',
    ].each do |value|
      describe value.inspect do
        it { is_expected.not_to allow_value(value) }
      end
    end
  end
end
