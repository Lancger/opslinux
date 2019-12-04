参考资料：

https://www.cnblogs.com/weavepub/p/11045025.html   Elasticsearch 7.1.1 集群 + 配置身份验证

https://juejin.im/post/5d80e994e51d4561de20b6a5  Elasticsearch节点，集群，分片及副本
  
https://blog.csdn.net/ypc123ypc/article/details/69944805  Elasticsearch Data too large Error排查过程

```
PUT _cluster/settings
{
  "persistent" : {
    "indices.breaker.fielddata.limit" : "20%" 
  }
}
```
