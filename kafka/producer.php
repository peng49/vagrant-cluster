<?php
/** @noinspection PhpComposerExtensionStubsInspection */
$conf = new RdKafka\Conf();
//$conf->set('log_level', (string) LOG_DEBUG);
//$conf->set('debug', 'all');
$conf->set('bootstrap.servers', '192.165.34.91:9092,192.165.34.92:9092,192.165.34.93:9092');

$rk = new RdKafka\Producer($conf);
//$rk->addBrokers("192.165.34.91:9092");

// Forget messages that are not fully sent yet
/*$rk->purge(RD_KAFKA_PURGE_F_QUEUE);
$rk->flush(1000);*/

$topic = $rk->newTopic("part01");

$count = 15;
while (true) {
    $count++;
    $topic->produce(RD_KAFKA_PARTITION_UA, 0, $count);
    if ($count % 2000 == 0) {
        sleep(1);
        var_dump($count);
    }
}
