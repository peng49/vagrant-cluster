<?php
/** @noinspection PhpComposerExtensionStubsInspection */
$conf = new RdKafka\Conf();
//$conf->set('log_level', (string) LOG_DEBUG);
//$conf->set('debug', 'all');
$conf->set('bootstrap.servers', '192.165.34.91:9092');

$rk = new RdKafka\Producer($conf);
$rk->addBrokers("192.165.34.91:9092");


$topic = $rk->newTopic("test3");
$option = 'qkl';
$topic->produce(RD_KAFKA_PARTITION_UA, 0, "qkl . 1", $option);
$topic->produce(RD_KAFKA_PARTITION_UA, 0, "qkl . 1", $option);
$topic->produce(RD_KAFKA_PARTITION_UA, 0, "qkl . 1", $option);
$topic->produce(RD_KAFKA_PARTITION_UA, 0, "qkl . 1", $option);
$topic->produce(RD_KAFKA_PARTITION_UA, 0, "qkl . 1", $option);
$topic->produce(RD_KAFKA_PARTITION_UA, 0, "qkl . 1", $option);
var_dump($topic);