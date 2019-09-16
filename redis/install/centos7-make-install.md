# 一、安装jemalloc
```
#yum安装jemalloc
yum install -y jemalloc

rpm -ql jemalloc
/usr/bin/jemalloc.sh
/usr/lib64/libjemalloc.so.1

#也可以编译安装，先下载jemalloc：

https://github.com/jemalloc/jemalloc/releases/download/4.2.1/jemalloc-4.2.1.tar.bz2

tar xvf jemalloc-4.2.1.tar.bz2
cd jemalloc-4.2.1
./configure --prefix=/usr/local/jemalloc
make && make install

ll /usr/local/jemalloc/

total 16
drwxr-xr-x 2 root root 4096 Nov  7 16:47 bin
drwxr-xr-x 3 root root 4096 Nov  7 16:47 include
drwxr-xr-x 3 root root 4096 Nov  7 16:47 lib
drwxr-xr-x 4 root root 4096 Nov  7 16:47 share

然后再编译redis的时候指定MALLOC，如下：

make MALLOC=/usr/local/jemalloc/lib

当Redis进程跑起来之后，在你的实例中使用info命令可以查看你所使用的内存管理器。

mem_allocator:jemalloc-4.2.1

如果你使用的是libc，那么mem_allocator的参数就会是libc。
```
# 二、安装 Redis

```
#1、安装依赖
yum -y install gcc gcc-c++ kernel-devel jemalloc

#2、下载，解压，编译安装
wget http://download.redis.io/releases/redis-4.0.10.tar.gz
tar -xzf redis-4.0.10.tar.gz
cd redis-4.0.10

#3、如果因为上次编译失败，有残留的文件
make distclean

#4、安装
make MALLOC=jemalloc PREFIX=/usr/local/redis install
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
```

# 三、配置环境变量和配置
```
vim /etc/profile
export PATH="$PATH:/usr/local/redis/bin"
# 保存退出

# 让环境变量立即生效
source /etc/profile

cat > /etc/redis/6379.conf <<-EOF
#bind 192.168.52.103
bind 0.0.0.0
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
requirepass bllnetwell!#@2019
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

# 四、redis启动脚本
```
cat > /usr/lib/systemd/system/redis.service <<-EOF
[Unit]
Description=Redis 6379
After=syslog.target network.target
[Service]
Type=forking
PrivateTmp=yes
Restart=always
ExecStart=/usr/bin/redis-server /etc/redis/6379.conf
ExecStop=/usr/bin/redis-cli -h 127.0.0.1 -p 6379 -a foobared shutdown
User=redis
Group=redis
LimitCORE=infinity
LimitNOFILE=100000
LimitNPROC=100000
[Install]
WantedBy=multi-user.target
EOF
```

# 五、redis服务启动
```
#刷新配置
systemctl daemon-reload

systemctl start redis
systemctl restart redis
systemctl stop redis

#开机自启动
systemctl enable redis
systemctl disable redis

#查看状态
systemctl status redis

```

# 六、系统参数优化
```
注意一
echo 511 > /proc/sys/net/core/somaxconn

注意二
vim /etc/sysctl.conf
然后sysctl -p 使配置文件生效
vm.overcommit_memory=1
或
sysctl vm.overcommit_memory=1
或
echo 1 > /proc/sys/vm/overcommit_memory

注意三
vim /etc/rc.local
新增
echo never > /sys/kernel/mm/transparent_hugepage/enabled
```


# 七、防火墙配置
```
#查看iptables现有规则
iptables -L -n

#先允许所有,不然有可能会杯具
iptables -P INPUT ACCEPT

#清空所有默认规则
iptables -F

#清空所有自定义规则
iptables -X

#所有计数器归0
iptables -Z

#允许来自于lo接口的数据包(本地访问)
iptables -A INPUT -i lo -j ACCEPT

#开放22端口
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

#开放21端口(FTP)
iptables -A INPUT -p tcp --dport 21 -j ACCEPT

#开放80端口(HTTP)
iptables -A INPUT -p tcp --dport 80 -j ACCEPT

#开放443端口(HTTPS)
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

#允许ping
iptables -A INPUT -p icmp --icmp-type 8 -j ACCEPT

#允许接受本机请求之后的返回数据 RELATED,是为FTP设置的
iptables -A INPUT -m state --state  RELATED,ESTABLISHED -j ACCEPT

#其他入站一律丢弃
iptables -P INPUT DROP

#所有出站一律绿灯
iptables -P OUTPUT ACCEPT

#所有转发一律丢弃
iptables -P FORWARD DROP

iptables -A INPUT -s 192.168.56.13 -p tcp --dport 6379 -j ACCEPT

```

# 八、测试连接
```
redis-cli -h 127.0.0.1 -a "foobared"  会弹出个警告
Warning: Using a password with '-a' option on the command line interface may not be safe.

#解决办法（2>/dev/null将标准错误去除即可）
redis-cli -h 127.0.0.1 -a "foobared" 2>/dev/null
```
参考文档：

https://segmentfault.com/a/1190000017780463  Centos7安装Redis 

http://www.144d.com/post-583.html

https://www.cnblogs.com/kreo/p/4368811.html  CentOS7安装iptables防火墙

https://www.ywnds.com/?p=6957  Redis安装报错error:jemalloc/jemalloc.h:No
