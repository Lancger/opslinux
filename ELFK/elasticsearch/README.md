# 一、Elasticsearch 相关 api 操作

## 1. 检查 es 集群健康状态
```bash
#bash命令
curl -XGET 'localhost:9200/_cat/health?v&pretty'

epoch      timestamp cluster       status node.total node.data shards pri relo init unassign pending_tasks max_task_wait_time active_shards_percent
1545296116 03:55:16  elasticsearch yellow          1         1     15  15    0    0       15             0                  -                 50.0%

#kibana命令
GET /_cat/health?v

描述：可以看到红框范围内的值为 yellow，它代表了我们 es 服务集群的健康状态，详细描述如下。解读后我们可以了解到，我们的 yellow 状态对于日常使用没有影响，它只是因为我们的集群暂时由单节点服务器组成，没有多余的节点分配给我们的分片副本了，解决示例会在以后的文章中给出。

RED: Damnit. Some or all of (primary) shards are not ready.
YELLOW: Elasticsearch has allocated all of the primary shards, but some/all of the replicas have not been allocated.
GREEN: Great. Your cluster is fully operational. Elasticsearch is able to allocate all shards and replicas to machines within the cluster.
```

## 2. 获取集群中的节点列表
```
#bash命令
curl -XGET 'localhost:9200/_cat/nodes?v?pretty'

192.168.56.138 192.168.56.138 6 91 0.01 d * Infant Terrible

#kibana命令
GET /_cat/nodes?v
```

## 3. 创建索引
```
#bash命令
curl -XPUT 'localhost:9200/customer?pretty&pretty'

#kibana命令
PUT /customer?pretty

返回示例：
{
  "acknowledged" : true
}
```

## 4、获取索引
```bash
#bash命令：
curl -XGET 'localhost:9200/_cat/indices?v&pretty'

health status index    pri rep docs.count docs.deleted store.size pri.store.size
yellow open   indexdb    5   1          1            0      3.7kb          3.7kb
yellow open   my-index   5   1          2            0      7.3kb          7.3kb
yellow open   my_index   5   1          2            0      6.9kb          6.9kb
yellow open   customer   5   1          0            0       795b           795b

#kibana命令：
GET /_cat/indices?v

描述： 该条指令用于获取所有索引列表
```

## 5. 删除索引
```bash

#bash命令：
curl -XDELETE 'localhost:9200/customer?pretty&pretty'

#kibana命令：
DELETE /customer?pretty

返回示例：
{
  "acknowledged" : true
}

描述： 通过添加 * 通配符，我们可以删除所有形如 customer2017-3-8-11-26-58的索引。

#删除所有所有
curl -XDELETE 'localhost:9200/*?pretty&pretty'
```

## 6. 索引文档
```bash

#bash命令
curl -XPUT 'localhost:9200/customer/external/1?pretty&pretty' -H 'Content-Type: application/json' -d'
{
  "name": "John",
  "age": 18
}
'

#再插入另外一条
curl -XPUT 'localhost:9200/customer/external/2?pretty&pretty' -H 'Content-Type: application/json' -d'
{
  "name": "Tom",
    "age": 20 
}
'
#注意这里更改了ID为2

#kibana命令
PUT /customer/external/1?pretty
{
  "name": "John Doe",
  "age": 20
}

返回示例：
{
  "_index" : "customer",
  "_type" : "external",
  "_id" : "1",
  "_version" : 1,
  "_shards" : {
    "total" : 2,
    "successful" : 1,
    "failed" : 0
  },
  "created" : true
}

描述：索引中可以存在不同的类型，我们刚刚便创建了类型 “external”及其文档，大家可以把它理解为关系型数据库中的表和列。索引时 ID 字段是可选的，假如我们没有指定，es 将自动为我们生成 ID（此种情况下需要使用 POST HTTPVerb）。
```

## 7. 查询文档
```
#bash命令
curl -XGET 'localhost:9200/customer/external/1?pretty&pretty'

#kibana命令
GET /customer/external/1?pretty

返回示例：
{
  "_index" : "customer",
  "_type" : "external",
  "_id" : "1",
  "_version" : 1,
  "found" : true,
  "_source" : {
    "name" : "John Doe"
  }
}
```

## 8.更新文档
```bash
#bash命令：
curl -XPOST 'localhost:9200/customer/external/1/_update?pretty&pretty' -H 'Content-Type: application/json' -d'
{
  "doc": { "name": "Jane Doe", "age": 20 }
}
'

#kibana命令：
POST /customer/external/1/_update?pretty
{
  "doc": { "name": "Jane Doe", "age": 20 }
}

返回示例：
{
  "_index" : "customer",
  "_type" : "external",
  "_id" : "1",
  "_version" : 2,
  "_shards" : {
    "total" : 2,
    "successful" : 1,
    "failed" : 0
  }
}

描述： 我们刚才针对之前录入的 customer 的某条 id 为 1 的数据进行了更新，并扩充了其属性。值得注意的是，当我们执行更新操作时，es 实际上是对索引的文档进行了删除并重建的操作，并不是真正意义上的更新。
```

## 9. 删除文档
```bash
#bash命令
curl -XDELETE 'localhost:9200/customer/external/1?pretty?pretty'

#kibana命令
DELETE /customer/external/1?pretty

返回示例
{"found":true,"_index":"customer","_type":"external","_id":"1","_version":6,"_shards":{"total":2,"successful":1,"failed":0}}
```

## 10. 批量查询文档
```bash
#bash命令：
curl -XGET 'localhost:9200/customer/external/_search?pretty'

#kibana命令：
GET /customer/external/_search?pretty

返回示例
{
  "took" : 8,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "failed" : 0
  },
  "hits" : {
    "total" : 2,
    "max_score" : 1.0,
    "hits" : [ {
      "_index" : "customer",
      "_type" : "external",
      "_id" : "2",
      "_score" : 1.0,
      "_source" : {
        "name" : "Tom",
        "age" : 20
      }
    }, {
      "_index" : "customer",
      "_type" : "external",
      "_id" : "1",
      "_score" : 1.0,
      "_source" : {
        "name" : "John Doe"
      }
    } ]
  }
}
```

## 11. 字符串查询文档
```
#bash命令： 
curl -XGET 'localhost:9200/customer/external/_search?q=name:Tom'

#kibana命令：
GET /customer/external/_search?q=name:Tom?pretty


返回示例
{"took":13,"timed_out":false,"_shards":{"total":5,"successful":5,"failed":0},"hits":{"total":1,"max_score":0.30685282,"hits":[{"_index":"customer","_type":"external","_id":"2","_score":0.30685282,"_source":
{
  "name": "Tom",
    "age": 20
}

描述： 字符串查询即是一种条件查询，q=name:Jane 即意味着我们想要查询 external 类型中属性 name 值含有 Jane 的文档，es 会自动将相关匹配返回给我们。假如想要了解更多，请参见 Simple Query String Query。
https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-simple-query-string-query.html#query-dsl-simple-query-string-query
```

## 12. DSL条件查询文档
```
#bash命令：
curl -XGET 'localhost:9200/customer/external/_search?pretty' -H 'Content-Type: application/json' -d'
{
    "query": {
        "match" : {
            "name":"Tom"
        }
    }
}
'

#kibana命令：
GET /customer/external/_search?pretty
{
    "query": {
        "match" : {
            "name":"Joe"
        }
    }
}
```

## 13. 批量更新文档
```
#bash命令：
curl -XPOST 'localhost:9200/customer/external/_bulk?pretty&pretty' -H 'Content-Type: application/json' -d'
{"index":{"_id":"AVqm6MRTU67sF7xAeJ5R"}}
{"name": "John Doe" }
{"index":{"_id":"AVqm6MURU67sF7xAeJ5S"}}
{"name": "Jane Doe" }
{"update":{"_id":"AVqm6MRTU67sF7xAeJ5R"}}
{"doc": { "name": "John Doe becomes Jane Doe" } }
{"delete":{"_id":"AVqm6MURU67sF7xAeJ5S"}}
'

#kibana命令：
POST /customer/external/_bulk?pretty
{"index":{"_id":"AVqm6MRTU67sF7xAeJ5R"}}
{"name": "John Doe" }
{"index":{"_id":"AVqm6MURU67sF7xAeJ5S"}}
{"name": "Jane Doe" }
{"update":{"_id":"AVqm6MRTU67sF7xAeJ5R"}}
{"doc": { "name": "John Doe becomes Jane Doe" } }
{"delete":{"_id":"AVqm6MURU67sF7xAeJ5S"}}
```

参考文档： https://www.cnblogs.com/Wddpct/archive/2017/03/26/6623191.html
