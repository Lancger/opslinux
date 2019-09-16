# 传入索引和关键参数查询
```
#!/usr/bin/env python
# _*_ coding:utf-8 _*_

from datetime import datetime
from elasticsearch import Elasticsearch
import json
import sys

es = Elasticsearch([{'host':'120.33.88.31','port':9200,}],timeout=60)

index = sys.argv[1]
key1 = sys.argv[2]
key2 = sys.argv[3]
now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
print now

#范围匹配所需字段查询
args = {
    "size": 10000,
    "query": { 
      "bool": { 
        "must": [
          { "match": { "cpod.state":   key1 }}, 
          { "match": { "cpod.code":    key2 }}  
        ],
        "filter": [ 
          { "range": { "time": { "lte": "now" }}} 
        ]
      }
    },
    "sort" : [{ "time" : { "order" : "asc"}}]
}

print args
resp = es.search(index, body=args)
resp_docs = resp['hits']['hits']

for item in resp_docs:
    print(item)
```

# 操作示例
```
[root@test ~]# python res_new.py agent-statistics-2019.01.09 200 10306
```
