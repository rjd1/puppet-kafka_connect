## rjd1-kafka_connect changelog

Release notes for the rjd1-kafka_connect module.

## Release 0.2.3

2023-12-08 - documentation updates

* Updated various portions of the docs

## Release 0.2.2

2023-10-30 - update to provider restart

* Updated provider restart POST to include failed tasks

## Release 0.2.1

2023-10-19 - removal of private class params

* Removed private class parameters, replaced with direct scoping

## Release 0.2.0

2023-10-18 - elimination of old dependency

* Removed hash_file resource in favor of to_json() content function
* Some minor manifest cleanup

## Release 0.1.0

2023-07-24 - initial version released as 0.1.0

* Initial release just containing connector management code
* Added type & provider pair, plus manage_connectors helper class
* Added spec tests, standard docs, etc.
