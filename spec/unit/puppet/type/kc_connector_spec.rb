# frozen_string_literal: true

require 'spec_helper'
require 'puppet/type/kc_connector'

describe Puppet::Type.type(:kc_connector) do
  it 'loads' do
    expect(described_class).not_to be_nil
  end

  it 'has name as its namevar' do
    expect(described_class.key_attributes).to eq([:name])
  end

  let :type do
    described_class.new(
      {
        name: 'test_connector',
        ensure: 'present',
        config_file: '/tmp/test_config.json',
      },
    )
  end

  it 'accepts ensure absent' do
    type[:ensure] = :absent
    expect(type[:ensure]).to eq(:absent)
  end

  it 'rejects invalid ensure' do
    expect { type[:ensure] = 'purged' }.to raise_error(Puppet::Error)
  end

  it 'accepts a name' do
    type[:name] = 'my_connector'
    expect(type[:name]).to eq('my_connector')
  end

  it 'accepts a config_file fully qualified path' do
    type[:config_file] = '/tmp/my_config.json'
    expect(type[:config_file]).to eq('/tmp/my_config.json')
  end

  it 'rejects a config_file non fully qualified path' do
    expect { type[:config_file] = 'my_config.json' }.to raise_error(%r{Config file path must be absolute})
  end

  it 'accepts a hostname' do
    type[:hostname] = 'test-kc-host'
    expect(type[:hostname]).to eq('test-kc-host')
  end

  it 'accepts a port integer' do
    type[:port] = 8082
    expect(type[:port]).to eq(8082)
  end

  it 'accepts a port integer string' do
    type[:port] = '8082'
    expect(type[:port]).to eq('8082')
  end

  it 'rejects a port string' do
    expect { type[:port] = 'seribu' }.to raise_error(%r{The port must be an integer})
  end

  it 'accepts an enable_delete boolean' do
    type[:enable_delete] = true
    expect(type[:enable_delete,]).to eq(true)
  end

  it 'rejects an enable_delete string' do
    expect { type[:enable_delete] = 'ohno' }.to raise_error(Puppet::Error)
  end

  it 'accepts a restart_on_failed_state boolean ' do
    type[:restart_on_failed_state] = true
    expect(type[:restart_on_failed_state]).to eq(true)
  end

  it 'rejects a restart_on_failed_state string' do
    expect { type[:restart_on_failed_state] = 'tidak' }.to raise_error(Puppet::Error)
  end

  it 'accepts a valid config_updated value' do
    type[:config_updated] = :unknown
    expect(type[:config_updated]).to eq(:unknown)
  end

  it 'rejects an invalid config_updated value' do
    expect { type[:config_updated] = :problynot }.to raise_error(Puppet::Error)
  end

  it 'accepts a valid connector_state_ensure value' do
    type[:connector_state_ensure] = :PAUSED
    expect(type[:connector_state_ensure]).to eq(:PAUSED)
  end

  it 'rejects an invalid connector_state_ensure value' do
    expect { type[:connector_state_ensure] = :ONFIRE }.to raise_error(Puppet::Error)
  end

  it 'rejects a non-default tasks_state_ensure value' do
    expect { type[:tasks_state_ensure] = :PAUSED }.to raise_error(Puppet::Error)
  end

  it 'defaults to hostname => localhost' do
    expect(type[:hostname]).to eq(:localhost)
  end

  it 'defaults to port => 8083' do
    expect(type[:port]).to eq(8083)
  end

  it 'defaults to enable_delete => false' do
    expect(type[:enable_delete]).to eq(false)
  end

  it 'defaults to restart_on_failed_state => false' do
    expect(type[:restart_on_failed_state]).to eq(false)
  end

  it 'defaults to config_updated => :yes' do
    expect(type[:config_updated]).to eq(:yes)
  end

  it 'defaults to connector_state_ensure => :RUNNING' do
    expect(type[:connector_state_ensure]).to eq(:RUNNING)
  end

  it 'defaults to tasks_state_ensure => :RUNNING' do
    expect(type[:tasks_state_ensure]).to eq(:RUNNING)
  end

  it 'is expected to have a refresh method' do
    expect(type).to respond_to(:refresh)
  end

  it 'autorequires the config file' do
    catalog = Puppet::Resource::Catalog.new
    file = Puppet::Type.type(:file).new(name: '/tmp/test_config.json')
    catalog.add_resource file
    catalog.add_resource type
    relationship = type.autorequire.find do |rel|
      (rel.source.to_s == "File[/tmp/test_config.json]") && (rel.target.to_s == type.to_s)
    end
    expect(relationship).to be_a Puppet::Relationship
  end

  it 'does not autorequire the config file if it is not managed' do
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource type
    expect(type.autorequire).to be_empty
  end
end
