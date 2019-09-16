# 一、条件查询
```
#!/usr/bin/env python
# _*_ coding:utf-8 _*_

from datetime import datetime
from elasticsearch import Elasticsearch
import json
import sys

es = Elasticsearch([{'host':'127.0.0.1','port':9200,}],timeout=60)

index = sys.argv[1]
key1 = sys.argv[2]
key2 = sys.argv[3]
now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
print now

#过滤条件：字段task_id为key1且字段pod.state为key2，且时间在过去1小时之间
#desc 降序排序
args = { 
  "size": 10,
  "from": 0,
  "query": {
    "bool": {
      "must": [
        {
          "match": {
            "cpod.state": key1
          }
        },
        {
          "match": {
            "task_id": key2
          }
        }
      ],
      "filter": [
        {
          "range": {
            '@timestamp': {
                'lt': 'now',
                'gt': 'now-2h'
            }
          }
        }
      ]
    }
  },
  "sort" : [{ "@timestamp" : { "order" : "desc"}}]
}

print args
resp = es.search(index, body=args)
resp_docs = resp['hits']['hits']

for item in resp_docs:
    print(item)
```

对应kibana界面的条件为
```
task_id:310000508 AND pod.state:200     --这里必须使用大写的AND条件
```
操作实例
```
python 1.py statistics-2019.03.20 200 310000508
```

## 二、聚合数量统计
```
#!/usr/bin/env python
# _*_ coding:utf-8 _*_

from datetime import datetime
from elasticsearch import Elasticsearch
import json
import sys

es = Elasticsearch([{'host':'127.0.0.1','port':9200,}],timeout=60)

index = sys.argv[1]
key1 = sys.argv[2]
key2 = sys.argv[3]
now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
print now

#过滤条件：字段task_id为key1且字段pod.state为key2，且时间在过去1小时之间
#desc 降序排序
args = { 
  "query": {
    "bool": {
      "must": [
        {
          "match": {
            "cpod.state": key1
          }
        },
        {
          "match": {
            "task_id": key2
          }
        }
      ],
      "filter": [
        {
          "range": {
            '@timestamp': {
                'lt': 'now',
                'gt': 'now-2h'
            }
          }
        }
      ]
    }
  }
}

print args
resp = es.search(index, body=args)
resp_docs = resp['hits']['hits']
total = resp['hits']['total']
print total

for item in resp_docs:
    print(item)
```
参考链接：


https://www.cnblogs.com/pilihaotian/p/5846332.html
