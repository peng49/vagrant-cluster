<?php
/** @noinspection PhpComposerExtensionStubsInspection */
$conf = new RdKafka\Conf();
//$conf->set('log_level', (string)LOG_DEBUG);
//$conf->set('debug', 'all');
$conf->set('bootstrap.servers', '192.165.34.91:9092,192.165.34.92:9092,192.165.34.93:9092');
$rk = new RdKafka\Consumer($conf);
//$rk->addBrokers("192.165.34.91:9092");

$topic = $rk->newTopic("part01");

// The first argument is the partition to consume from.
// The second argument is the offset at which to start consumption. Valid values
// are: RD_KAFKA_OFFSET_BEGINNING, RD_KAFKA_OFFSET_END, RD_KAFKA_OFFSET_STORED.
$topic->consumeStart(0, RD_KAFKA_OFFSET_BEGINNING);//设置开始消费的offset

while (true) {
    // The first argument is the partition (again).
    // The second argument is the timeout.
    $msg = $topic->consume(0, 1000);
    if (null === $msg || $msg->err === RD_KAFKA_RESP_ERR__PARTITION_EOF) {
        continue;
    } elseif ($msg->err) {
        echo $msg->errstr(), "\n";
        break;
    } else {
        echo $msg->offset,' ',$msg->payload, "\n";
        @sleep(1);
    }
}