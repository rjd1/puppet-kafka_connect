# @summary Validate the individual secret data.
type Kafka_connect::Secret = Struct[
  {
    Optional['ensure']     => Enum['absent', 'present', 'file'],
    Optional['connectors'] => Array[String[1]],
    Optional['key']        => String[1],
    Optional['value']      => String[1],
    Optional['kv_data']    => Hash[String[1], String[1]],
  }
]
