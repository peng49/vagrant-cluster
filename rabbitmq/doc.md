### php使用rabbitmq
[AMQP api文档](http://docs.php.net/manual/da/book.amqp.php)

##### rabbitmq概念

##### 安装extension
> php -m

查看是否安装 amqp 扩展,有安装的话跳过这一步，没有的话开始安装
```shell
# 查看php版本
$ php -v
PHP 7.3.29 (cli) (built: Jun 29 2021 12:30:03) ( NTS MSVC15 (Visual C++ 2017) x64 )
Copyright (c) 1997-2018 The PHP Group
Zend Engine v3.3.29, Copyright (c) 1998-2018 Zend Technologies
```

**Window安装**

打开 [https://pecl.php.net/package/amqp](https://pecl.php.net/package/amqp) 点击**DLL**进去下载对应的版本
![](./images/001.jpg)
![](./images/002.jpg)
解压下载的压缩文件,复制指定文件到对应的目录
![](./images/003.jpg)

**Linux安装**

通过编译安装的php

打开 [https://pecl.php.net/package/amqp](https://pecl.php.net/package/amqp) 下载压缩包
![](./images/004.jpg)

通过yum安装的php

##### 生产消息
```php
<?php
        $conn = new AMQPConnection([
            'host' => '192.165.34.71',
            'vhost' => 'vhost',
            'port' => 5672,
            'login' => 'test',
            'password' => 'test'
        ]);
        
        $conn->connect();
        
        $ch = new AMQPChannel($conn);
        $exchange = new AMQPExchange($ch);
        $exchange->setType(AMQP_EX_TYPE_DIRECT);
        $exchange->setFlags(AMQP_DURABLE);
        $exchange->setName('amq.direct');
        $exchange->declareExchange();
        
        $q = new AMQPQueue($ch);
        $q->setFlags(AMQP_DURABLE);
        $q->setName('queue001');
        $q->declareQueue();
        $q->bind($exchange->getName(), 'queue001-route-key');
        
        $message = "Hello World!";
        
        $exchange->publish($message, 'queue001-route-key');
```


##### 消费消息
```php
        $conn = new AMQPConnection([
            'host' => '192.165.34.71',
            'vhost' => 'vhost',
            'port' => 5672,
            'login' => 'test',
            'password' => 'test'
        ]);
        
        $conn->connect();
        
        $ch = new AMQPChannel($conn);     
        
        $q = new AMQPQueue($ch);
        $q->setFlags(AMQP_DURABLE);
        $q->setName('queue001');
        $q->declareQueue();

        while ($message = $q->get()) {
            if (empty($message)) {
                //@sleep(1);
                //continue;
                break;
            }
            var_dump($message->getBody());

            var_dump($message->getRoutingKey());
            var_dump($message->getExchangeName());           
            $q->ack($message->getDeliveryTag());
        }
```

##### 死信队列
创建一个死信队列
```php
        $conn = new AMQPConnection([
            'host' => '192.165.34.71',
            'vhost' => 'vhost',
            'port' => 5672,
            'login' => 'test',
            'password' => 'test'
        ]);

        $conn->connect();
        
        $ch = new AMQPChannel($conn);
        $exchange = new AMQPExchange($ch);
        // exchange 类型指定为 fanout        
        $exchange->setType(AMQP_EX_TYPE_FANOUT);
        $exchange->setFlags(AMQP_DURABLE);
        $exchange->setName('dlx.exchange');
        $exchange->declareExchange();

        $q = new AMQPQueue($ch);
        $q->setFlags(AMQP_DURABLE);
        $q->setName('dlx.queue');
        $q->declareQueue();
        
        while (true) {
            $message = $q->get();
            if (empty($message)) {
                //@sleep(1);
                //continue;
                break;
            }
            var_dump($message->getBody());
            $q->ack($message->getDeliveryTag());
        }
```

```php
<?php
        $conn = new AMQPConnection([
            'host' => '192.165.34.71',
            'vhost' => 'vhost',
            'port' => 5672,
            'login' => 'test',
            'password' => 'test'
        ]);

        $conn->connect();

        $ch = new AMQPChannel($conn);

        $exchange = new AMQPExchange($ch);
        $exchange->setType(AMQP_EX_TYPE_DIRECT);
        $exchange->setFlags(AMQP_DURABLE);
        $exchange->setName('amq.direct');
        $exchange->declareExchange();

        $q = new AMQPQueue($ch);
        $q->setFlags(AMQP_DURABLE);
        $q->setName('ttl.queue');
        //设置死信队列exchange
        $q->setArgument('x-dead-letter-exchange', 'dlx.exchange');
        //设置消息超过60秒自动过期
        $q->setArgument('x-message-ttl',60000);
        $q->declareQueue();
        $q->bind($exchange->getName(), $q->getName());

        for ($i = 0; $i < 20; $i++) {
            if ($i > 10) {
                $exchange->publish(strval($i), 'ttl.queue', AMQP_DURABLE);
            } else {
                $exchange->publish(strval($i), 'ttl.queue', AMQP_DURABLE, [
                    //设置消息的过期时间为20秒，推送之后20秒可以看到有10条消息通过 dlx.exchange 进入 dlx.queue
                    //60秒后剩下的消息过期，全部进入 dlx.queue 队列
                    'expiration' => 20000,
                    'delivery_mode' => 2
                ]);
            }
        }
```

**参考资料**
[和耳朵 RabbitMQ 专栏](https://juejin.cn/column/6960607399388381197)