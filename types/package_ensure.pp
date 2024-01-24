# @summary This type accepts (nearly) all possible package resource ensure options
type Kafka_connect::Package_ensure = Variant[SemVer, Enum['present', 'installed', 'latest', 'absent', 'purged']]
