[六千字呕心沥血深度总结，为您揭秘ClickHouse为什么查询这么快！](https://www.jianshu.com/p/140c677b2d46)

[Clickhouse主键如何工作以及如何选择](https://medium.com/datadenys/how-clickhouse-primary-key-works-and-how-to-choose-it-4aaf3bf4a8b9)

[Quick Start](https://clickhouse.com/docs/en/quick-start)

[实操，ClickHouse高可用集群部署](https://blog.51cto.com/feko/2738319)



测试数据
https://clickhouse.com/docs/zh/getting-started/example-datasets/uk-price-paid

下载到本地后，将下载下来的文件 `pp-complete.csv` 复制到 `/var/lib/clickhouse/user_files` 目录下

```clickhouse
CREATE TABLE uk_price_paid
(
    price UInt32,
    date Date,
    postcode1 LowCardinality(String),
    postcode2 LowCardinality(String),
    type Enum8('terraced' = 1, 'semi-detached' = 2, 'detached' = 3, 'flat' = 4, 'other' = 0),
    is_new UInt8,
    duration Enum8('freehold' = 1, 'leasehold' = 2, 'unknown' = 0),
    addr1 String,
    addr2 String,
    street LowCardinality(String),
    locality LowCardinality(String),
    town LowCardinality(String),
    district LowCardinality(String),
    county LowCardinality(String)
)
    ENGINE = MergeTree
        ORDER BY (postcode1, postcode2, addr1, addr2);



INSERT INTO uk_price_paid
WITH
    splitByChar(' ', postcode) AS p
SELECT toUInt32(price_string) AS price,
       parseDateTimeBestEffortUS(time) AS date,
       p[1] AS postcode1,
       p[2] AS postcode2,
       transform(a, ['T', 'S', 'D', 'F', 'O'], ['terraced', 'semi-detached', 'detached', 'flat', 'other']) AS type,
       b = 'Y' AS is_new,
       transform(c, ['F', 'L', 'U'], ['freehold', 'leasehold', 'unknown']) AS duration,
       addr1,
       addr2,
       street,
       locality,
       town,
       district,
       county FROM file('pp-complete.csv','CSV',
                   'uuid_string String,
                   price_string String,
                   time String,
                   postcode String,
                   a String,
                   b String,
                   c String,
                   addr1 String,
                   addr2 String,
                   street String,
                   locality String,
                   town String,
                   district String,
                   county String,
                   d String,
                   e String');
```
