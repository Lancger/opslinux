# 一、概述
```
Redis_Master      172.31.234.36   6379
Redis_Slave       172.31.234.37   6379

Redis_Sentinel1   172.31.234.36   16379
Redis_Sentinel2   172.31.234.37   16379
Redis_Sentinel3   172.31.234.37   16380
```
# 二、安装

```
#1、安装依赖
yum -y install gcc gcc-c++ kernel-devel

#2、下载，解压，编译安装
cd /usr/local/src/
wget http://download.redis.io/releases/redis-4.0.10.tar.gz
tar -xzf redis-4.0.10.tar.gz
cd redis-4.0.10

#3、如果因为上次编译失败，有残留的文件
make distclean

#4、安装
make MALLOC=libc PREFIX=/usr/local/redis install
mkdir /etc/redis/
cp redis.conf /etc/redis/6379.conf
cd /usr/local/redis/bin/
cp redis-benchmark redis-cli redis-server /usr/bin/

#创建用户
useradd redis -M -s /sbin/nologin

#创建日志文件
touch /var/log/redis_6379.log
mkdir -p /data0/redis_data
chown -R redis:redis /data0/redis_data
chown -R redis:redis /var/log/redis_6379.log

tail -100f /var/log/redis_6379.log

#master配置
cat >/etc/redis/6379.conf << \EOF
bind 172.31.234.36
protected-mode no
port 6379
tcp-backlog 511
timeout 0
tcp-keepalive 300
daemonize yes
supervised no
pidfile /var/run/redis_6379.pid
loglevel notice
logfile /var/log/redis_6379.log
databases 16
always-show-logo yes
save 900 1
save 300 10
save 60 10000
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
dbfilename dump.rdb
dir /data0/redis_data
slave-serve-stale-data yes
slave-read-only yes
repl-diskless-sync no
repl-diskless-sync-delay 5
repl-disable-tcp-nodelay no
slave-priority 100
requirepass Allwell!#@2019
lazyfree-lazy-eviction no
lazyfree-lazy-expire no
lazyfree-lazy-server-del no
slave-lazy-flush no
appendonly no
appendfilename "appendonly.aof"
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes
aof-use-rdb-preamble no
lua-time-limit 5000
slowlog-log-slower-than 10000
slowlog-max-len 128
latency-monitor-threshold 0
notify-keyspace-events ""
hash-max-ziplist-entries 512
hash-max-ziplist-value 64
list-max-ziplist-size -2
list-compress-depth 0
set-max-intset-entries 512
zset-max-ziplist-entries 128
zset-max-ziplist-value 64
hll-sparse-max-bytes 3000
activerehashing yes
client-output-buffer-limit normal 0 0 0
client-output-buffer-limit slave 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60
hz 10
aof-rewrite-incremental-fsync yes
rename-command FLUSHDB ""
rename-command FLUSHALL ""
EOF

#slave配置
cat >/etc/redis/6379.conf << \EOF
bind 172.31.234.37
slaveof 172.31.234.36 6379
masterauth Allwell!#@2019
protected-mode no
port 6379
tcp-backlog 511
timeout 0
tcp-keepalive 300
daemonize yes
supervised no
pidfile /var/run/redis_6379.pid
loglevel notice
logfile /var/log/redis_6379.log
databases 16
always-show-logo yes
save 900 1
save 300 10
save 60 10000
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
dbfilename dump.rdb
dir /data0/redis_data
slave-serve-stale-data yes
slave-read-only yes
repl-diskless-sync no
repl-diskless-sync-delay 5
repl-disable-tcp-nodelay no
slave-priority 100
requirepass Allwell!#@2019
lazyfree-lazy-eviction no
lazyfree-lazy-expire no
lazyfree-lazy-server-del no
slave-lazy-flush no
appendonly no
appendfilename "appendonly.aof"
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes
aof-use-rdb-preamble no
lua-time-limit 5000
slowlog-log-slower-than 10000
slowlog-max-len 128
latency-monitor-threshold 0
notify-keyspace-events ""
hash-max-ziplist-entries 512
hash-max-ziplist-value 64
list-max-ziplist-size -2
list-compress-depth 0
set-max-intset-entries 512
zset-max-ziplist-entries 128
zset-max-ziplist-value 64
hll-sparse-max-bytes 3000
activerehashing yes
client-output-buffer-limit normal 0 0 0
client-output-buffer-limit slave 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60
hz 10
aof-rewrite-incremental-fsync yes
rename-command FLUSHDB ""
rename-command FLUSHALL ""
EOF
```

# 三、配置

1、哨兵一配置
```

mkdir -p /data0/redis_data/sentinel_16379
chown -R redis:redis /data0/redis_data/

port 16379
daemonize yes
protected-mode no
dir "/data0/redis_data/sentinel_16379"
logfile "/var/log/redis_16379.log"
sentinel monitor mymaster 172.31.234.36 6379 1
sentinel down-after-milliseconds mymaster 5000
sentinel parallel-syncs mymaster 1
sentinel auth-pass mymaster Allwell!#@2019 
sentinel failover-timeout mymaster 15000
```

2、哨兵二配置
```
mkdir -p /data0/redis_data/sentinel_16379
chown -R redis:redis /data0/redis_data/

port 16379
daemonize yes
protected-mode no
dir "/data0/redis_data/sentinel_16379"
logfile "/var/log/redis_16379.log"
sentinel monitor mymaster 172.31.234.36 6379 1
sentinel down-after-milliseconds mymaster 5000
sentinel parallel-syncs mymaster 1
sentinel auth-pass mymaster Allwell!#@2019 
sentinel failover-timeout mymaster 15000
```


3、哨兵二配置
```
mkdir -p /data0/redis_data/sentinel_16380
chown -R redis:redis /data0/redis_data/

port 16380
daemonize yes
protected-mode no
dir "/data0/redis_data/sentinel_16380"
logfile "/var/log/redis_16380.log"
sentinel monitor mymaster 172.31.234.36 6379 1
sentinel down-after-milliseconds mymaster 5000
sentinel parallel-syncs mymaster 1
sentinel auth-pass mymaster Allwell!#@2019 
sentinel failover-timeout mymaster 15000
```


# 四、服务启动
```
#启动redis_server
redis-server /etc/redis/6379.conf 

#启动redis_sentinel
redis-sentinel /etc/redis/1679.conf 

redis-sentinel /etc/redis/16380.conf 
```

参考文档：

https://www.cnblogs.com/yjmyzz/p/redis-sentinel-sample.html   redis 学习笔记(4)-HA高可用方案Sentinel配置 
