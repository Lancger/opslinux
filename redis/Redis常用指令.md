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

# 四、Redis command 统计

部分显示的统计信息是基于命令类型的。包括调用次数、耗费CPU时间、每个命令平均耗费CPU。

```bash
INFO all

# Commandstats
cmdstat_get:calls=10701389,usec=40587034,usec_per_call=3.79
cmdstat_set:calls=9464518,usec=75001252,usec_per_call=7.92
cmdstat_setex:calls=1517,usec=32897,usec_per_call=21.69
cmdstat_del:calls=9559539,usec=33066579,usec_per_call=3.46
cmdstat_rpush:calls=9456699,usec=54998591,usec_per_call=5.82
cmdstat_lpop:calls=9456698,usec=51766153,usec_per_call=5.47
cmdstat_llen:calls=10681347,usec=49961993,usec_per_call=4.68
cmdstat_lrange:calls=26,usec=342,usec_per_call=13.15
cmdstat_hset:calls=2320496,usec=24788034,usec_per_call=10.68
cmdstat_hget:calls=15971821,usec=70126696,usec_per_call=4.39
cmdstat_hmset:calls=71183,usec=4393191,usec_per_call=61.72
cmdstat_hmget:calls=1147675,usec=8114188,usec_per_call=7.07
cmdstat_hdel:calls=1670141,usec=1869100,usec_per_call=1.12
cmdstat_hgetall:calls=1138,usec=11945,usec_per_call=10.50
cmdstat_hexists:calls=6481244,usec=46845131,usec_per_call=7.23
cmdstat_expire:calls=1088,usec=6135,usec_per_call=5.64
cmdstat_keys:calls=2524,usec=90522,usec_per_call=35.86
cmdstat_ping:calls=86390517,usec=134478145,usec_per_call=1.56
cmdstat_info:calls=3,usec=37258,usec_per_call=12419.33
cmdstat_monitor:calls=3,usec=12,usec_per_call=4.00
```

参考文档：

http://www.runoob.com/redis/redis-hashes.html
