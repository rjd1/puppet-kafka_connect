require 'puppet/util'
require 'puppet/parameter/boolean'

Puppet::Type.newtype(:kc_connector) do
  @doc = '@summary Native type for Kafka Connect connector management.

    Manages running KC connectors.

    **Autorequires:** If Puppet is managing the connector config file,
    the kc_connector resource will autorequire that file.

    @see https://github.com/rjd1/puppet-kafka_connect#managing-connectors-directly-through-the-resource-type'

  ensurable

  newparam(:name, namevar: true) do
    desc 'The name of the connector resource you want to manage.'
  end

  newparam(:config_file) do
    desc 'Config file fully qualified path.'
    # isrequired
    validate do |value|
      unless Puppet::Util.absolute_path? value
        raise ArgumentError, "Config file path must be absolute: #{value}"
      end
    end
  end

  newparam(:hostname) do
    desc 'The hostname or IP of the KC service.'
    defaultto(:localhost)
  end

  newparam(:port) do
    desc 'The listening port of the KC service.'
    validate do |value|
      unless %r{^\d+$}.match?(value.to_s)
        raise ArgumentError, _('The port must be an integer.')
      end
    end
    defaultto(8083)
  end

  newparam(:enable_delete, boolean: true, parent: Puppet::Parameter::Boolean) do
    desc 'Flag to enable delete, required for remove action.'
    defaultto(:false)
  end

  newparam(:restart_on_failed_state, boolean: true, parent: Puppet::Parameter::Boolean) do
    desc 'Flag to enable auto restart on FAILED connector state.'
    defaultto(:false)
  end

  newproperty(:config_updated) do
    desc 'Property to ensure running config matches file config.'
    newvalues(:yes, :no, :unknown)
    defaultto(:yes)
  end

  newproperty(:connector_state_ensure) do
    desc 'State of the connector to ensure.'
    newvalues(:RUNNING, :PAUSED, :STOPPED)
    defaultto(:RUNNING)
  end

  newproperty(:tasks_state_ensure) do
    desc 'State of the connector tasks to ensure. This is just used to catch failed tasks and should not be changed.'
    newvalues(:RUNNING)
    defaultto(:RUNNING)
  end

  def refresh
    provider.restart
  end

  autorequire(:file) do
    [self[:config_file]]
  end
end
