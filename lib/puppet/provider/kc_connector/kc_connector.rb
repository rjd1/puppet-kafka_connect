require 'fileutils'
require 'json'
require 'net/http'
require 'uri'

Puppet::Type.type(:kc_connector).provide(:kc_connector) do
  desc <<-DESC
    '@summary Provider for Kafka Connect connector management.

    Manages live KC connectors.'
  DESC

  def self.instances
    connectors_raw = Net::HTTP.get('localhost', '/connectors', '8083')

    begin
      connectors_arr = JSON.parse(connectors_raw)
    rescue JSON::ParserError
      raise(Puppet::Error, "Unable to parse connectors output as JSON: #{connectors_raw}")
    end

    Puppet.debug("Checked for existing connectors...\n connectors_raw: #{connectors_raw}\n connectors_arr: #{connectors_arr}")

    connectors_arr.map do |connector|
      resource = {}
      resource[:name] = connector
      resource[:ensure] = :present
      resource[:config_updated] = :unknown
      resource[:provider] = :kc_connector
      Puppet.debug("Resource hash for connector #{connector}: #{resource}")
      new(resource)
    end
  end

  def exists?
    get_output = Net::HTTP.get(@resource.value(:hostname).to_s, "/connectors/#{@resource[:name]}", @resource.value(:port).to_s)

    Puppet.debug("Checked if #{@resource[:name]} exists...\n get_output: #{get_output}")

    if get_output.match?(%r{Connector\s#{name}\snot\sfound})
      false
    else
      true
    end
  end

  def create
    if @resource.value(:config_file).nil? || !File.exist?(@resource.value(:config_file).to_s)
      raise(Puppet::Error, "Missing or invalid config_file param value, so unable to create #{@resource[:name]}.")
    end

    config_data = File.read(@resource.value(:config_file).to_s)
    connectors_uri = URI("http://#{@resource[:hostname]}:#{@resource[:port]}/connectors")
    http = Net::HTTP.new(@resource.value(:hostname).to_s, @resource.value(:port).to_s)
    request = Net::HTTP::Post.new(connectors_uri, 'Content-Type' => 'application/json')
    request.body = config_data

    response = http.request(request)

    if response.is_a?(Net::HTTPInternalServerError) || response.is_a?(Net::HTTPBadRequest)
      raise(Puppet::Error, "Create failed with http response: #{response} #{response.body}")
    elsif !response.is_a?(Net::HTTPSuccess)
      Puppet.warning("Unexpected response on create attempt: #{response} #{response.body}")
    end

    Puppet.debug("Attempted to create #{@resource[:name]}...\n")
    Puppet.debug(" config_data: #{config_data}\n connectors_uri: #{connectors_uri}\n request: #{request}\n response: #{response}")
  end

  def destroy
    if resource[:enable_delete]
      net = Net::HTTP.new(@resource.value(:hostname).to_s, @resource.value(:port).to_s)
      destroy_response = net.send_request('DELETE', "/connectors/#{@resource[:name]}")

      unless destroy_response.is_a?(Net::HTTPNoContent)
        Puppet.warning("Unexpected response encountered on remove attempt: #{destroy_response}\n ")
      end

      Puppet.debug("Attempted to delete #{@resource[:name]}...\n net: #{net}\n destroy_response: #{destroy_response}")
    else
      Puppet.warning("#{@resource[:name]} is set to absent, but not actually removing since enable_delete=false.")
    end
  end

  def config_updated
    if @resource.value(:config_file).nil?
      Puppet.debug("Parameter config_file undefined for #{@resource[:name]}...\n")
      return 'unknown'
    end

    unless File.exist?(@resource.value(:config_file).to_s)
      Puppet.debug("Config file #{@resource[:config_file]} not found for #{@resource[:name]}...\n")
      return 'unknown'
    end

    file_config_data = File.read(@resource.value(:config_file).to_s)

    begin
      file_datahash = JSON.parse(file_config_data)
    rescue JSON::ParserError
      raise(Puppet::Error, "Unable to parse file config data as JSON: #{file_config_data}")
    end

    file_datahash = file_datahash.values[1] # first key-value pair (0) is name, second is config hash

    live_config_data = Net::HTTP.get(@resource.value(:hostname).to_s, "/connectors/#{@resource[:name]}/config", @resource.value(:port).to_s)

    begin
      live_datahash = JSON.parse(live_config_data)
    rescue JSON::ParserError
      raise(Puppet::Error, "Unable to parse live config data as JSON: #{live_config_data}")
    end

    live_datahash.tap { |cd| cd.delete('name') }

    compare_result = live_datahash.sort == file_datahash.sort

    Puppet.debug("Attempted to check if configs match for #{@resource[:name]}...\n")
    Puppet.debug(" live_config_data: #{live_config_data}\n live_datahash: #{live_datahash}")
    Puppet.debug(" file_config_data: #{file_config_data}\n file_datahash: #{file_datahash}\n compare_result : #{compare_result}")

    if compare_result
      'yes'
    else
      'no'
    end
  end

  def config_updated=(value)
    if @resource.value(:config_file).nil? || !File.exist?(@resource.value(:config_file).to_s)
      Puppet.warning("Missing or invalid config_file param value, so unable to ensure config_updated=#{value} for #{@resource[:name]}.")
    else
      config_data = File.read(@resource.value(:config_file).to_s)
      config_parsed = JSON.parse(config_data)
      config_hash = config_parsed['config']
      json_config_hash = JSON.generate(config_hash)

      connectors_uri = URI("http://#{@resource[:hostname]}:#{@resource[:port]}/connectors/#{@resource[:name]}/config")
      http = Net::HTTP.new(@resource.value(:hostname).to_s, @resource.value(:port).to_s)
      request = Net::HTTP::Put.new(connectors_uri, 'Content-Type' => 'application/json')
      request.body = json_config_hash

      response = http.request(request)

      if response.is_a?(Net::HTTPInternalServerError) || response.is_a?(Net::HTTPBadRequest)
        raise(Puppet::Error, "Config update attempt failed with http response: #{response} #{response.body}")
      elsif !response.is_a?(Net::HTTPSuccess)
        Puppet.warning("Unexpected response on config update attempt: #{response} #{response.body}")
      end

      Puppet.debug("Attempted to update config for #{@resource[:name]}...\n")
      Puppet.debug(" json_config: #{config_data}\n connectors_uri: #{connectors_uri}\n request: #{request}\n response: #{response}")
    end
  end

  def check_connector_state
    conn_state_raw = Net::HTTP.get(@resource.value(:hostname).to_s, "/connectors/#{@resource[:name]}/status", @resource.value(:port).to_s)

    begin
      conn_state_parsed = JSON.parse(conn_state_raw)
    rescue JSON::ParserError
      raise(Puppet::Error, "Unable to parse connector status output as JSON: #{conn_state_raw}")
    end

    connector_state = conn_state_parsed['connector']['state']

    tasks_array = conn_state_parsed['tasks']

    if tasks_array.any? { |t| t['state'] == 'FAILED' }
      tasks_state = 'FAILED'
      failed_tasks = tasks_array.select { |t| t['state'] == 'FAILED' }
      failed_task_ids = failed_tasks.map { |t| t['id'] }
    else
      # assume running if not failed
      tasks_state = 'RUNNING'
      failed_task_ids = []
    end

    Puppet.debug("Attempted to check connector state for #{@resource[:name]}...\n")
    Puppet.debug(" conn_state_raw: #{conn_state_raw}")
    Puppet.debug(" conn_state_parsed: #{conn_state_parsed}")
    Puppet.debug(" connector_state: #{connector_state}")
    Puppet.debug(" tasks_array: #{tasks_array}")
    Puppet.debug(" tasks_state: #{tasks_state}")
    Puppet.debug(" failed_task_ids: #{failed_task_ids}")

    state = { connector: connector_state, tasks: tasks_state, failed_task_ids: failed_task_ids }

    state
  end

  def connector_state_ensure
    check_connector_state[:connector]
  end

  def connector_state_ensure=(value)
    current_state = check_connector_state[:connector].to_s
    value = value.to_s

    Puppet.debug("current_state for #{@resource[:name]}: #{current_state}, setter value: #{value}")

    http = Net::HTTP.new(@resource.value(:hostname).to_s, @resource.value(:port).to_s)

    if current_state == 'RUNNING' && value == 'PAUSED'
      Puppet.debug("Attempting to change from RUNNING state to PAUSED for #{@resource[:name]}...")

      response = http.send_request('PUT', "/connectors/#{@resource[:name]}/pause")

      unless response.is_a?(Net::HTTPAccepted)
        Puppet.warning("Unexpected response encountered on pause attempt: #{response}\n ")
      end
    elsif current_state == 'PAUSED' && value == 'RUNNING'
      Puppet.debug("Attempting to change from PAUSED state to RUNNING for #{@resource[:name]}...")

      response = http.send_request('PUT', "/connectors/#{@resource[:name]}/resume")

      unless response.is_a?(Net::HTTPAccepted)
        Puppet.warning("Unexpected response encountered on resume attempt: #{response}\n ")
      end
    elsif current_state == 'FAILED' && resource[:restart_on_failed_state]
      restart
    elsif current_state == 'FAILED' && !resource[:restart_on_failed_state]
      Puppet.warning("restart_on_failed_state not enabled, so skipping for connector #{@resource[:name]}.")

      response = nil
    elsif ['RESTARTING', 'UNASSIGNED'].include?(current_state)
      Puppet.warning("Current state of the connector is #{current_state}, so skipping state change for #{@resource[:name]}.")

      response = nil
    else
      Puppet.debug("Conditonal failed to match in connector_state_ensure setter for connector #{@resource[:name]}.")

      raise(Puppet::Error, "Unexpected connector state: #{current_state}")
    end

    return unless !response.nil?

    Puppet.debug("response: #{response}")
  end

  def tasks_state_ensure
    check_connector_state[:tasks]
  end

  def tasks_state_ensure=(value)
    check_state_output = check_connector_state

    connector_state = check_state_output[:connector].to_s
    tasks_state = check_state_output[:tasks].to_s
    failed_task_ids = check_state_output[:failed_task_ids]
    value = value.to_s

    if connector_state == 'FAILED'
      Puppet.warning("Connector state found to be FAILED on #{@resource[:name]}, so not attempting to restart individual failed task id(s) #{failed_task_ids}. They will be restarted along with the connector (if enabled).") # rubocop:disable Layout/LineLength
      return
    elsif connector_state != 'RUNNING'
      Puppet.warning("Connector state not found to be RUNNING (instead: #{connector_state}) on #{@resource[:name]}, so not attempting to restart failed task id(s) #{failed_task_ids}.")
      return
    end

    unless tasks_state == 'FAILED' && value == 'RUNNING'
      raise(Puppet::Error, "Expected to ensure RUNNING with tasks state FAILED, but got ensure #{value} with tasks state #{tasks_state} for #{@resource[:name]}")
    end

    if resource[:restart_on_failed_state]
      failed_task_ids.each do |id|
        restart_task(id)
      end
    else
      Puppet.warning("restart_on_failed_state not enabled, so skipping for failed task id(s) #{failed_task_ids} on connector #{@resource[:name]}.")
    end
  end

  def restart
    Puppet.notice("Restarting connector #{@resource[:name]} ...")

    http = Net::HTTP.new(@resource.value(:hostname).to_s, @resource.value(:port).to_s)
    response = http.send_request('POST', "/connectors/#{@resource[:name]}/restart?includeTasks=true&onlyFailed=true")

    return if response.is_a?(Net::HTTPNoContent) || response.is_a?(Net::HTTPAccepted)

    Puppet.warning("Unexpected response encountered on connector restart attempt: #{response}\n ")
  end

  def restart_task(id)
    Puppet.notice("Restarting task id #{id} on connector #{@resource[:name]} ...")

    http = Net::HTTP.new(@resource.value(:hostname).to_s, @resource.value(:port).to_s)
    response = http.send_request('POST', "/connectors/#{@resource[:name]}/tasks/#{id}/restart")

    return if response.is_a?(Net::HTTPNoContent) || response.is_a?(Net::HTTPAccepted)

    Puppet.warning("Unexpected response encountered on task restart attempt: #{response}\n ")
  end
end
