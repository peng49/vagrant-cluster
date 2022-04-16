<?php
/** @noinspection PhpComposerExtensionStubsInspection */
$conf = new RdKafka\Conf();
//$conf->set('log_level', (string) LOG_DEBUG);
//$conf->set('debug', 'all');
$conf->set('bootstrap.servers', '192.165.34.91:9092');

$rk = new RdKafka\Producer($conf);
//$rk->addBrokers("192.165.34.91:9092");

// Forget messages that are not fully sent yet
/*$rk->purge(RD_KAFKA_PURGE_F_QUEUE);
$rk->flush(1000);*/

$topic = $rk->newTopic("test5");

while (true) {
    for ($i = 1; $i < 20; $i++) {
        $topic->produce(RD_KAFKA_PARTITION_UA, 0, "qkl4 . " . date('Y-m-d H:i:s').rand(0,100000));
    }
    sleep(1);
}
var_dump($topic);