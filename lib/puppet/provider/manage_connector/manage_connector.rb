require 'fileutils'
require 'json'
require 'net/http'
require 'uri'

Puppet::Type.type(:manage_connector).provide(:manage_connector) do
  desc 'Manage live Kafka Connect connectors.'

  def self.instances
    #connectors_raw = Net::HTTP.get("#{@resource[:hostname]}", '/connectors', "#{@resource[:port]}")
    connectors_raw = Net::HTTP.get("localhost", '/connectors', "8083")

    begin
      connectors_arr = JSON.parse(connectors_raw)
    rescue JSON::ParserError
      fail("Unable to parse connectors output as JSON: #{connectors_raw}")
    end

    Puppet.debug("Checked for existing connectors...\n connectors_raw: #{connectors_raw}\n connectors_arr: #{connectors_arr}")

    connectors_arr.collect do |connector|
      resource = {}
      resource[:name] = connector
      resource[:ensure] = :present
      resource[:config_updated] = :unknown
      resource[:provider] = :manage_connector
      Puppet.debug("Resource hash for connector #{connector}: #{resource}")
      new(resource)
    end
  end

  def exists?
    get_output = Net::HTTP.get("#{@resource[:hostname]}", "/connectors/#{@resource[:name]}", "#{@resource[:port]}")

    Puppet.debug("Checked if #{@resource[:name]} exists...\n get_output: #{get_output}")

    if get_output =~ /Connector\s#{name}\snot\sfound/
      return false
    else
      return true
    end
  end

  def create
    if @resource.value(:config_file).nil? || !File.exist?("#{@resource[:config_file]}")
      raise Puppet::Error, "Missing or invalid config_file param value, so unable to create #{@resource[:name]}."
    end

    config_data = File.read("#{@resource[:config_file]}")
    connectors_uri = URI("http://#{@resource[:hostname]}:#{@resource[:port]}/connectors")
    http = Net::HTTP.new("#{@resource[:hostname]}", "#{@resource[:port]}")
    request = Net::HTTP::Post.new(connectors_uri, 'Content-Type' => 'application/json')
    request.body = config_data

    response = http.request(request)

    if response.kind_of?(Net::HTTPInternalServerError) || response.kind_of?(Net::HTTPBadRequest)
      raise Puppet::Error, "Create failed with http response: #{response} #{response.body}"
    elsif !response.kind_of?(Net::HTTPSuccess)
      Puppet.warning("Unexpected response on create attempt: #{response} #{response.body}")
    end

    Puppet.debug("Attempted to create #{@resource[:name]}...\n")
    Puppet.debug(" config_data: #{config_data}\n connectors_uri: #{connectors_uri}\n request: #{request}\n response: #{response}")
  end

  def destroy
    if resource[:enable_delete]
      net = Net::HTTP.new("#{@resource[:hostname]}", "#{@resource[:port]}")
      destroy_response = net.send_request('DELETE', "/connectors/#{@resource[:name]}")

      if !destroy_response.kind_of?(Net::HTTPNoContent)
        Puppet.warning("Unexpected response encountered on remove attempt: #{destroy_response}\n ")
      end

      Puppet.debug("Attempted to delete #{@resource[:name]}...\n net: #{net}\n destroy_response: #{destroy_response}")
    else
      Puppet.warning("The following connector is set to absent, but not removing since delete is not enabled: #{@resource[:name]}")
    end
  end

  def config_updated
    if @resource.value(:config_file).nil?
      Puppet.debug("Parameter config_file undefined for #{@resource[:name]}...\n")
      return 'unknown'
    end

    if !File.exist?("#{@resource[:config_file]}")
      Puppet.debug("Config file #{@resource[:config_file]} not found for #{@resource[:name]}...\n")
      return 'unknown'
    end

    file_config_data = File.read("#{@resource[:config_file]}")

    begin
      file_datahash = JSON.parse(file_config_data)
    rescue JSON::ParserError
      fail("Unable to parse file config data as JSON: #{file_config_data}")
    end

    file_datahash = file_datahash.values[1] # first key-value pair (0) is name, second is config hash

    live_config_data = Net::HTTP.get("#{@resource[:hostname]}", "/connectors/#{@resource[:name]}/config", "#{@resource[:port]}")

    begin
      live_datahash = JSON.parse(live_config_data)
    rescue JSON::ParserError
      fail("Unable to parse live config data as JSON: #{live_config_data}")
    end

    live_datahash.tap { |cd| cd.delete('name') }

    compare_result = live_datahash.sort == file_datahash.sort

    Puppet.debug("Attempted to check if configs match for #{@resource[:name]}...\n")
    Puppet.debug(" live_config_data: #{live_config_data}\n live_datahash: #{live_datahash}")
    Puppet.debug(" file_config_data: #{file_config_data}\n file_datahash: #{file_datahash}\n compare_result : #{compare_result}")

    if compare_result
      return 'yes'
    else
      return 'no'
    end
  end

  def config_updated=(value)
    if @resource.value(:config_file).nil? || !File.exist?("#{@resource[:config_file]}")
      Puppet.warning("Missing or invalid config_file param value, so unable to ensure config_updated=#{value} for #{@resource[:name]}.")
    else
      config_data = File.read("#{@resource[:config_file]}")
      config_parsed = JSON.parse(config_data)
      config_hash = config_parsed['config']
      json_config_hash = JSON.generate(config_hash)

      connectors_uri = URI("http://#{@resource[:hostname]}:#{@resource[:port]}/connectors/#{@resource[:name]}/config")
      http = Net::HTTP.new("#{@resource[:hostname]}", "#{@resource[:port]}")
      request = Net::HTTP::Put.new(connectors_uri, 'Content-Type' => 'application/json')
      request.body = json_config_hash

      response = http.request(request)

      if response.kind_of?(Net::HTTPInternalServerError) || response.kind_of?(Net::HTTPBadRequest)
        raise Puppet::Error, "Config update attempt failed with http response: #{response} #{response.body}"
      elsif !response.kind_of?(Net::HTTPSuccess)
        Puppet.warning("Unexpected response on config update attempt: #{response} #{response.body}")
      end

      Puppet.debug("Attempted to update config for #{@resource[:name]}...\n")
      Puppet.debug(" json_config: #{config_data}\n connectors_uri: #{connectors_uri}\n request: #{request}\n response: #{response}")
    end
  end

  def check_connector_state
    conn_state_raw = Net::HTTP.get("#{@resource[:hostname]}", "/connectors/#{@resource[:name]}/status", "#{@resource[:port]}")

    begin
      conn_state_parsed = JSON.parse(conn_state_raw)
    rescue JSON::ParserError
      fail("Unable to parse connector status output as JSON: #{conn_state_raw}")
    end

    connector_state = conn_state_parsed['connector']['state']

    Puppet.debug("Attempted to check connector state for #{@resource[:name]}...\n")
    Puppet.debug(" conn_state_raw: #{conn_state_raw}")
    Puppet.debug(" conn_state_parsed: #{conn_state_parsed}")
    Puppet.debug(" connector_state: #{connector_state}")

    return connector_state
  end

  def connector_state_ensure
    check_connector_state
  end

  def connector_state_ensure=(value)
    current_state = check_connector_state.to_s
    value = value.to_s

    Puppet.debug("current_state for #{@resource[:name]}: #{current_state}, setter value: #{value}")

    http = Net::HTTP.new("#{@resource[:hostname]}", "#{@resource[:port]}")

    if current_state == "RUNNING" && value == "PAUSED"
      Puppet.debug("Attempting to change from RUNNING state to PAUSED for #{@resource[:name]}...")

      response = http.send_request('PUT', "/connectors/#{@resource[:name]}/pause")

      if !response.kind_of?(Net::HTTPAccepted)
        Puppet.warning("Unexpected response encountered on pause attempt: #{response}\n ")
      end
    elsif current_state == "PAUSED" && value == "RUNNING"
      Puppet.debug("Attempting to change from PAUSED state to RUNNING for #{@resource[:name]}...")

      response = http.send_request('PUT', "/connectors/#{@resource[:name]}/resume")

      if !response.kind_of?(Net::HTTPAccepted)
        Puppet.warning("Unexpected response encountered on resume attempt: #{response}\n ")
      end
    elsif current_state == "FAILED" && resource[:restart_on_failed_state]
      restart
    elsif current_state == "FAILED" && !resource[:restart_on_failed_state]
      Puppet.warning("Restart on failed state not enabled, so skipping for connector #{@resource[:name]}.")

      response = nil
    elsif current_state == "RESTARTING" || current_state == "UNASSIGNED"
      Puppet.warning("Current state of the connector is #{current_state}, so skipping state change for #{@resource[:name]}.")

      response = nil
    else
      Puppet.debug("Conditonal failed to match in connector_state_ensure setter for connector #{@resource[:name]}.")

      raise Puppet::Error, "Unexpected connector state: #{current_state}"
    end

    if !response.nil?
      Puppet.debug("response: #{response}")
    end

  end

  def restart
      Puppet.notice("Restarting connector #{@resource[:name]}...")

      http = Net::HTTP.new("#{@resource[:hostname]}", "#{@resource[:port]}")
      #response = http.send_request('POST', "/connectors/#{@resource[:name]}/restart")
      response = http.send_request('POST', "/connectors/#{@resource[:name]}/restart?includeTasks=true&onlyFailed=true")

      unless response.kind_of?(Net::HTTPNoContent) || response.kind_of?(Net::HTTPAccepted)
        Puppet.warning("Unexpected response encountered on restart attempt: #{response}\n ")
      end
  end

end
