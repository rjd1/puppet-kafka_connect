# @summary Validate the individual connector data.
type Kafka_connect::Connector = Struct[
  {
    Optional['ensure'] => Enum['absent', 'present', 'running', 'paused'],
    'name'             => String[1],
    'config'           => Hash[String[1], String],
  }
]
