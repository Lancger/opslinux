# 一、带时间参数范围查询
```
cat res_new.py 

#!/usr/bin/env python
# _*_ coding:utf-8 _*_

from datetime import datetime
from elasticsearch import Elasticsearch
import json
import sys

es = Elasticsearch([{'host':'10.33.99.31','port':9200}])

index = sys.argv[1]
sn = sys.argv[2]
now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
print now

#范围匹配所需字段查询
args = {
    "query": {
        "range" : {
            "time": {
                "lt": now,
                "gt": "now-15min"
            }
        }
    },
    "_source" : ["sn","source","epod.state"]
}

print args
resp = es.search(index, body=args)
resp_docs = resp['hits']['hits']

for item in resp_docs:
    print(item['_source'])
    
    
注意，这里的now 是es自动获取的时间
```
## 运行结果
```
python res_new.py agent-statistics-2018.12.21 310003258

{'query': {'range': {'time': {'lt': '2018-12-21 17:20:47'}}}, '_source': ['sn', 'source', 'epod.state']}
{u'source': u'/data/log/statistics/task.log', u'sn': u'C002116', u'epod': {u'state': 200}}
{u'source': u'/data/log/statistics/task.log', u'sn': u'B364348', u'epod': {u'state': 400}}
{u'source': u'/data/log/statistics/task.log', u'sn': u'1134851', u'epod': {u'state': 200}}
{u'source': u'/data/log/statistics/task.log', u'sn': u'C013054', u'epod': {u'state': 200}}
{u'source': u'/data/log/statistics/task.log', u'sn': u'A143240', u'epod': {u'state': 200}}
{u'source': u'/data/log/statistics/task.log', u'sn': u'1222146', u'epod': {u'state': 200}}
{u'source': u'/data/log/statistics/task.log', u'sn': u'1248760', u'epod': {u'state': 200}}
{u'source': u'/data/log/statistics/task.log', u'sn': u'B367195', u'epod': {u'state': 200}}
{u'source': u'/data/log/statistics/task.log', u'sn': u'C223570', u'epod': {u'state': 200}}
{u'source': u'/data/log/statistics/task.log', u'sn': u'C046516', u'epod': {u'state': 200}}
```


# 二、多个条件
```
[root@localhost ~]# cat 1.py
#!/usr/bin/env python
# _*_ coding:utf-8 _*_

from datetime import datetime
from elasticsearch import Elasticsearch
import json
import sys

# es = Elasticsearch([{'host':'10.33.99.31','port':9200}])
es = Elasticsearch()

index = sys.argv[1]
key = sys.argv[2]
now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
print now

#bool查询
query = {
  "query": {
    "bool": {
      "must": [
        { "match": { "name":      key     }}
      ],
      "filter": [
        { "range": { "age": { "gte": "10" }}}
      ]
    }
  },
  "sort": [ { "age": { "order": "desc" } } ],
  "size": 100,
  "_source" : ["age"]
}

resp = es.search(index, body=query)
resp_docs = resp['hits']['hits']

for item in resp_docs:
    print(item['_source'])
```

## 运行结果
```
[root@localhost ~]# python 1.py customer Tom
2018-12-21 22:48:05
{u'age': 200}
{u'age': 100}
{u'age': 20}
```

参考资料：

https://www.cnblogs.com/sunfie/p/6653778.html
