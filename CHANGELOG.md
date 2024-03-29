## rjd1-kafka_connect changelog

Release notes for the rjd1-kafka_connect module.

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
