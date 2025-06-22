## rjd1-kafka_connect changelog

Release notes for the rjd1-kafka_connect module.

## Release 3.4.0

2025-06-22 - Support stopping connectors

 - Add support for setting connector state to stopped
 - Update logic in helper class to not require config data for paused or stopped states
 - Add openvox to metadata.json

## Release 3.3.0

2025-04-28 - Support setting performance opts var + jvm options in standalone mode

 - Add support for setting KAFKA_JVM_PERFORMANCE_OPTS value via new $kafka_jvm_performance_options param
 - Add support for setting heap & performance opts configs in standalone mode

## Release 3.2.0

2025-04-07 - Support alt java class + dep updates

 - Support including an alternative/custom java class, via new $java_class_name param
 - Use load_module_metadata() to support older puppetlabs-stdlib versions
 - Allow puppetlabs-apt 10.x

## Release 3.1.2

2025-03-01 - Update PDK

 - Update PDK to 3.4.0
 - Various doc updates

## Release 3.1.1

2025-01-03 - Fix type autorequire

 - Fix autorequire resource bug for config file in the custom type
 - Various rspec updates

## Release 3.1.0

2024-12-04 - Update supported Operating Systems

 - Add Amazon Linux 2023
 - Add RedHat, Rocky 8 & 9
 - Drop EOL CentOS

## Release 3.0.0

2024-10-23 - Support Apache archive install source + other enhancements

 - Add support for installing from archive source (Apache .tgz)
 - Add optional management of user & group resources
 - Add optional management of systemd service unit file(s)
 - Use new defined type for hub plugin installs
 - Remove deprecated $connectors_absent & $connectors_paused class params
 - Deprecate $owner in favor of new $user param
 - Set default package version to 7.7.1
 - Add support for Ubuntu 24.04
 - Update module dependencies

## Release 2.5.0

2024-09-03 - Support standalone mode

 - Add support for standalone mode setup
 - Allow puppetlabs-java 11.x

## Release 2.4.1

2024-06-19 - Update deprecated function

 - Changed to_json() to the namespaced stdlib::to_json()
 - Require puppetlabs-stdlib 9.x
 - Improved yum clean command
 - Moved wait exec into the service class

## Release 2.4.0

2024-05-22 - Type/Provider enhancement

 - Added tasks_state_ensure property and support for restarting individual failed tasks

## Release 2.3.0

2024-05-02 - Class restructuring

 - Added individual sub-classes for repo resources
 - Split manage connector stuff into separate sub-classes
 - Added an exec to flush the yum cache
 - Added optional $service_provider parameter
 - Various rspec test updates

## Release 2.2.0

2024-04-16 - Improved secrets support

 - Added support for multiple key/value pairs in each secret file

## Release 2.1.0

2024-04-02 - Support Ubuntu

 - Fixed resource ordering with apt repo
 - Added support for Ubuntu 22.04

## Release 2.0.0

2024-03-19 - Renaming libs

 - Renamed the type and provider pair
 - Various updates based on 'pdk validate' output

## Release 1.4.0

2024-03-05 - Functionality & usage enhancements

 - Added support for 'ensure' key in connector data
 - Added data types aliases for connectors & secrets
 - Improved logic with error checking and notifies
 - Deprecated use of $kafka_connect::connectors_absent
 - Deprecated use of $kafka_connect::connectors_paused

## Release 1.3.0

2024-02-19 - Improved logging support

 - Added support for time-based log rotation
 - Added ability to enable sending logs to stdout/console
 - Added support for setting custom log4j config lines
 - Some various class updates

## Release 1.2.0

2024-01-29 - Parameter updates & class enhancements

 - Updated a bunch of data types to be more strict
 - Converted a couple config params from String to Integer
 - Added a pair of new params for setting file modes
 - Added logic to set config file ensures dynamically
 - Added use of contain()
 - Updated Strings docs

## Release 1.1.0

2024-01-15 - Support removing secret files

 - Added ability to set secret files to absent via 'ensure' hash key
 - Fixed a bug where the provider would improperly warn on restart

## Release 1.0.1

2024-01-05 - Doc updates

 - Fixed syntax error in class example
 - A few updates to the README
 - Some minor class cleanup

## Release 1.0.0

2023-12-14 - Support for distributed mode setup

 - Added confluent_repo, install, config, & service classes
 - Added template configs
 - Spec test adds & updates
 - Updated docs

## Release 0.2.3

2023-12-08 - Documentation updates

 - Updated various portions of the docs

## Release 0.2.2

2023-10-30 - Update to provider restart

 - Updated provider restart POST to include failed tasks

## Release 0.2.1

2023-10-19 - Removal of private class params

 - Removed private class parameters, replaced with direct scoping

## Release 0.2.0

2023-10-18 - Elimination of old dependency

 - Removed hash_file resource in favor of to_json() content function
 - Some minor manifest cleanup

## Release 0.1.0

2023-07-24 - Initial version released as 0.1.0

 - Initial release just containing connector management code
 - Added type & provider pair, plus manage_connectors helper class
 - Added spec tests, standard docs, etc.
