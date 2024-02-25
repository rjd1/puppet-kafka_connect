# @summary Validate the individual secret data.
type Kafka_connect::Secret = Struct[
  {
    Optional['ensure']     => Enum['absent', 'present', 'file'],
    Optional['connectors'] => Array[String[1]],
    'key'                  => String[1],
    'value'                => String[1],
  }
]
