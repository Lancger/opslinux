# 一、安装依赖

```
yum -y install automake
yum -y install libtool
yum -y install autoconf
yum -y install bzip2
```

# 二、软件编译安装
```
1、官方链接：https://github.com/vipshop/redis-migrate-tool
软件编译安装：

cd /usr/local/src/
wget https://github.com/vipshop/redis-migrate-tool/archive/master.zip
unzip master.zip
mv redis-migrate-tool-master redis-migrate-tool
cd redis-migrate-tool
mkdir data
autoreconf -fvi
./configure
make
src/redis-migrate-tool -h

2、检查安装是否成功，如下图所示即为正确
src/redis-migrate-tool -h
```

# 三、配置启动redis-migrate-tool
```
3.1）配置文件实例：

vim /tmp/rmt.conf

示例1：从rdb文件恢复数据到redis cluster集群

[source]
type: rdb file
servers:
 - /data/redis/dump1.rdb
 - /data/redis/dump2.rdb
 - /data/redis/dump3.rdb

[target]
type: redis cluster
servers:
 - 127.0.0.1:7379

[common]
listen: 0.0.0.0:8888


示例2：从redis cluster集群迁移数据到另外一个cluster集群

[source]
type: redis cluster
servers:
- 127.0.0.1:8379

[target]
type: redis cluster
servers:
- 127.0.0.1:7379

[common]
listen: 0.0.0.0:8888

示例3：从redis cluster集群迁移数据到twemproxy集群

[source]
type: redis cluster
servers:
- 127.0.0.1:6379

[target]
type: twemproxy
hash: fnv1a_64
hash_tag: "{}"
distribution: ketama
servers:
- 127.0.0.1:6380:1 server1
- 127.0.0.1:6381:1 server2
- 127.0.0.1:6382:1 server3
- 127.0.0.1:6383:1 server4

[common]
listen: 0.0.0.0:34345
threads: 8
step: 1
mbuf_size: 512
source_safe: true

3.2）软件运行：

cd /usr/local/src/redis-migrate-tool
src/redis-migrate-tool -c rmt.conf -o log -d

3.3）状态查看：通过redis-cli连接redis-migrate-tool监控的端口，运行info命令

$redis-cli -h 127.0.0.1 -p 8888
127.0.0.1:8888> info
# Server
version:0.1.0
os:Linux 2.6.32-573.12.1.el6.x86_64 x86_64
multiplexing_api:epoll
gcc_version:4.4.7
process_id:9199
tcp_port:8888
uptime_in_seconds:1662
uptime_in_days:0
config_file:/ect/rmt.conf

# Clients
connected_clients:1
max_clients_limit:100
total_connections_received:3

# Memory
mem_allocator:jemalloc-4.0.4

# Group
source_nodes_count:32
target_nodes_count:48

# Stats
all_rdb_received:1
all_rdb_parsed:1
rdb_received_count:32
rdb_parsed_count:32
total_msgs_recv:7753587
total_msgs_sent:7753587
total_net_input_bytes:234636318
total_net_output_bytes:255384129
total_net_input_bytes_human:223.77M
total_net_output_bytes_human:243.55M
total_mbufs_inqueue:0
total_msgs_outqueue:0
127.0.0.1:8888>

3.4）数据校验：

$src/redis-migrate-tool -c rmt.conf -o log -C redis_check
Check job is running...

Checked keys: 1000
Inconsistent value keys: 0
Inconsistent expire keys : 0
Other check error keys: 0
Checked OK keys: 1000

All keys checked OK!
Check job finished, used 1.041s


```

# 四、附加工具：redis-port

1、安装go

```

wget https://dl.google.com/go/go1.7.5.linux-amd64.tar.gz
tar zxvf go1.7.5.linux-amd64.tar.gz
mv go /usr/local/
mkdir $HOME/work
echo 'export GOROOT=/usr/local/go' >>/etc/profile 
echo 'export PATH=$PATH:$GOROOT/bin' >>/etc/profile
echo 'export GOPATH=$HOME/work' >>/etc/profile
source /etc/profile
# go version
go version go1.7.5 linux/amd64

```
2、下载 redis-port
```
http://docs-aliyun.cn-hangzhou.oss.aliyun-inc.com/assets/attach/66008/cn_zh/1522293930203/redis-port.redis-port?spm=a2c4g.11186623.2.4.hUAhx7&file=redis-port.redis-port
```

3、使用示例1

```
./redis-port  restore  --input=x/dump.rdb  --target=dst_host:dst_port   --auth=dst_password  
[--filterkey="str1|str2|str3"] [--targetdb=DB] [--rewrite] [--bigkeysize=SIZE] [--logfile=REDISPORT.LOG]
参数说明

x/dump.rdb : 自建 redis 的 dump 文件路径
dst_host : 目的数据库 redis 域名
dst_port : 目的数据库 redis 端口
dst_password : 目的数据库 redis 密码
str1|str2|str3 : 过滤具有 str1 或 str2 或 str3 的 key
DB : 将要同步入目的数据库 redis 的 DB
rewrite : 覆盖已经写入的 key
bigkeysize=SIZE : 当写入的 value 大于 SIZE 时，走大 key 写入模式


根据 redis-port 日志查看数据同步状态

根据redis-port日志查看同步状态

当出现restore: rdb done时数据同步完成。
```

4、使用示例2

```
./redis-port  sync  --from=src_host:src_port --password=src_password  --target=dst_host:dst_port   
--auth=dst_password  [--filterkey="str1|str2|str3"] [--targetdb=DB] [--rewrite] [--bigkeysize=SIZE] 
[--logfile=REDISPORT.LOG]
参数说明

src_host : 自建 redis 域名（或者 IP）
src_port : 自建 redis 端口
src_password : 自建 redis 密码
dst_host : 目的数据库 redis 域名
dst_port : 目的数据库 redis 端口
dst_password : 目的数据库 redis 密码
str1|str2|str3 : 过滤具有 str1 或 str2 或 str3 的 key
DB : 将同步入目的 redis 的 DB
rewrite : 覆盖已经写入的 key
bigkeysize=SIZE : 当写入的 value 大于 SIZE 时，走大 key 写入模式

根据 redis-port 日志查看数据同步状态

根据redis-port日志查看同步状态当出现sync rdb done时全量同步完成，进入增量同步的模式。
```

参考资料：

https://blog.51cto.com/qiangsh/2104767?utm_source=oschina-app  Redis Cluster在线迁移

https://blog.51cto.com/8370646/2170479  redis迁移工具redis-migrate-tool测试
