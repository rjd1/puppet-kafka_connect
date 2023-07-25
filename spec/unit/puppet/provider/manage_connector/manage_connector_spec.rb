# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'

ensure_module_defined('Puppet::Provider::ManageConnector')
require 'puppet/provider/manage_connector/manage_connector'

describe Puppet::Type.type(:manage_connector).provider(:manage_connector) do

  let(:resource) { Puppet::Type.type(:manage_connector).new({
    :name        => 'foo-connector',
    :ensure      => :present,
    :port        => '80',
    :provider    => :manage_connector,
    :config_file => '/tmp/config-foo.json',
  })}

  let(:provider) { resource.provider }

  let(:config_file_content) { '{"name":"foo-connector","config":{"foo.setting":"bar"}}' }
  let(:config_file_content_alt) { '{"name":"foo-connector","config":{"bar.setting":"foo"}}' }

  before :each do
    stub_request(:get, "http://localhost/connectors").
      with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
      to_return(body: '["foo-connector"]')
    stub_request(:get, "http://localhost/connectors/foo-connector").
      with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
      to_return(body: '{"name":"foo-connector","config":{"foo.setting":"bar","partition.duration.ms":"180000"},"tasks":[{"connector":"foo-connector","task":0}],"type":"foo"}')
    stub_request(:get, "http://localhost/connectors/foo-connector/config").
      with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
      to_return(body: '{"foo.setting":"bar"}')
    stub_request(:get, "http://localhost/connectors/foo-connector/status").
      with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
      to_return(body: '{"name":"foo-connector","connector":{"state":"RUNNING","worker_id":"127.0.0.1:80"},"tasks":[{"id":"0","state":"RUNNING","worker_id":"127.0.0.1:80"}],"type":"foo"}')
    stub_request(:post, "http://localhost/connectors").
      with(body: "{\"name\":\"foo-connector\",\"config\":{\"foo.setting\":\"bar\"}}",
         headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'Host'=>'localhost', 'User-Agent'=>'Ruby'})
    stub_request(:post, "http://localhost/connectors/foo-connector/restart").
      with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'})
  end

  it 'should have an exists? method' do
    expect(provider).to respond_to(:exists?)
  end

  it 'should have a create method' do
    expect(provider).to respond_to(:create)
  end

  it 'should have a config_updated method' do
    expect(provider).to respond_to(:config_updated)
  end

  it 'should have a config_updated= method' do
    expect(provider).to respond_to(:config_updated=)
  end

  it 'should have a destroy method' do
    expect(provider).to respond_to(:destroy)
  end

  it 'should have a check_connector_state method' do
    expect(provider).to respond_to(:check_connector_state)
  end

  it 'should have a connector_state_ensure method' do
    expect(provider).to respond_to(:connector_state_ensure)
  end

  it 'should have a connector_state_ensure= method' do
    expect(provider).to respond_to(:connector_state_ensure=)
  end

  it 'should have a restart method' do
    expect(provider).to respond_to(:restart)
  end

  describe 'checking existence' do
    it 'should check for the connector' do
      expect(provider.exists?).to eq true
    end
  end

  describe 'creating' do
    it 'should create the resource' do
      allow(File).to receive(:exist?).with(resource[:config_file]).and_return(true)
      allow(File).to receive(:read).with(resource[:config_file]).and_return(config_file_content)
      provider.create
    end
  end

  describe 'compares config' do
    it 'is updated' do
      allow(File).to receive(:exist?).with(resource[:config_file]).and_return(true)
      allow(File).to receive(:read).with(resource[:config_file]).and_return(config_file_content)
      expect(provider.config_updated).to eq 'yes'
    end

    it 'is not updated' do
      allow(File).to receive(:exist?).with(resource[:config_file]).and_return(true)
      allow(File).to receive(:read).with(resource[:config_file]).and_return(config_file_content_alt)
      expect(provider.config_updated).to eq 'no'
    end
  end

  describe 'checking state' do
    it 'should check the connector state' do
      expect(provider.check_connector_state).to eq 'RUNNING'
    end
  end

  describe 'restarting' do
    it 'should restart the connector' do
      provider.restart
    end
  end

  describe 'destroying' do
    it 'should destroy the resource' do
      provider.destroy
    end
  end

end
