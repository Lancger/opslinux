## 一、查询redis key的数量
```
info可以看到所有库的key数量

dbsize则是当前库key的数量

keys *这种数据量小还可以，大的时候可以直接搞死生产环境。

dbsize和keys *统计的key数可能是不一样的，如果没记错的话，keys *统计的是当前db有效的key，而dbsize统计的是所有未被销毁的key（有效和未被销毁是不一样的，具体可以了解redis的过期策略）
```

## 二、查询key的类型
```
127.0.0.1:7381> type Test_Business
hash
127.0.0.1:7381> 

返回值
返回 key 的数据类型，数据类型有：

    none (key不存在)
    string (字符串)
    list (列表)
    set (集合)
    zset (有序集)
    hash (哈希表)

```

## 三、Redis 哈希(Hash)操作
```
127.0.0.1:6379>  HMSET runoobkey name "redis tutorial" description "redis basic commands for caching" likes 20 visitors 23000
OK
127.0.0.1:6379>  HGETALL runoobkey
1) "name"
2) "redis tutorial"
3) "description"
4) "redis basic commands for caching"
5) "likes"
6) "20"
7) "visitors"
8) "23000"


#删除字段
HDEL runoobkey name
```




参考文档：

http://www.runoob.com/redis/redis-hashes.html
