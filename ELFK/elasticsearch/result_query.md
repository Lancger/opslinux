# 一、标准查询
```
[root@localhost ~]# cat result_query.py
#!/usr/bin/env python
# _*_ coding:utf-8 _*_

from datetime import datetime
from elasticsearch import Elasticsearch
import json

es = Elasticsearch()

index = "customer"

#标准匹配
query = {
"query":{
    "match":{
       "name":"Tom"
      }
   }
}

resp = es.search(index, body=query)
resp_docs = resp['hits']['hits']

for item in resp_docs:
    print(item['_source'])
```
## 查询结果
```
[root@localhost ~]# python result_query.py
{u'age': 20, u'name': u'Tom'}
```

# 二、范围查询
```
[root@localhost ~]# cat result_multi.py
#!/usr/bin/env python
# _*_ coding:utf-8 _*_

from datetime import datetime
from elasticsearch import Elasticsearch
import json

es = Elasticsearch()

index = "customer"

#范围匹配
query = {
"query":{
    "range":{
       "age":{
          "gte": 10,
          "lt": 30
        }
      }
   }
}

resp = es.search(index, body=query)
resp_docs = resp['hits']['hits']

for item in resp_docs:
    print(item['_source'])
```
## 查询结果
```
[root@localhost ~]# python result_multi.py
{u'age': 20, u'name': u'Tom'}
```

# 三、bool查询接口(带变量)
```
[root@localhost ~]# cat result_bool.py
#!/usr/bin/env python
# _*_ coding:utf-8 _*_

from datetime import datetime
from elasticsearch import Elasticsearch
import json
import sys

es = Elasticsearch()

#index = "customer"
index = sys.argv[1]
age = sys.argv[2]

#bool查询
query = {
   "query": {
       "bool":{
           "must":{
               "term":{"age":age}
           }
       }
   }
}

resp = es.search(index, body=query)
resp_docs = resp['hits']['hits']

for item in resp_docs:
    print(item['_source'])
    
```
## 查询结果
```
[root@localhost ~]# python result_bool.py customer 20
{u'age': 20, u'name': u'Tom'}
```
参考资料:

https://www.cnblogs.com/kongzhagen/p/7899346.html
