# @summary Validate the Confluent Hub plugins list.
type Kafka_connect::HubPlugins = Array[Optional[Pattern[/^\w+\/[a-zA-z0-9]{1,}[a-zA-z0-9\-]{0,}:(\d+\.\d+\.\d+|latest)$/]]]
