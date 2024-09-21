# @summary Validate the Confluent Hub plugin.
type Kafka_connect::HubPlugin = Pattern[/^\w+\/[a-zA-z0-9]{1,}[a-zA-z0-9\-]{0,}:(\d+\.\d+\.\d+|latest)$/]
