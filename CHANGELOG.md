## rjd1-kafka_connect changelog

Release notes for the rjd1-kafka_connect module.

## Release 1.0.0

2023-12-14 - Support for distributed mode setup

* Added confluent_repo, install, config, & service classes
* Added template configs
* Spec test adds & updates
* Updated docs

## Release 0.2.3

2023-12-08 - Documentation updates

* Updated various portions of the docs

## Release 0.2.2

2023-10-30 - Update to provider restart

* Updated provider restart POST to include failed tasks

## Release 0.2.1

2023-10-19 - Removal of private class params

* Removed private class parameters, replaced with direct scoping

## Release 0.2.0

2023-10-18 - Elimination of old dependency

* Removed hash_file resource in favor of to_json() content function
* Some minor manifest cleanup

## Release 0.1.0

2023-07-24 - Initial version released as 0.1.0

* Initial release just containing connector management code
* Added type & provider pair, plus manage_connectors helper class
* Added spec tests, standard docs, etc.
