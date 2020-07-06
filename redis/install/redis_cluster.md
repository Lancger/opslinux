# CentOs7.5搭建Redis-4.0.1 Cluster集群服务

## 一、环境

    VMware版本号：12.0.0
    CentOS版本：CentOS 7.5.1804
    三台虚拟机(IP)：
    192.168.56.11
    192.168.56.12
    192.168.56.13

## 二、注意事项

    #1、安裝 GCC 编译工具 不然会有编译不过的问题
    yum install -y gcc g++ gcc-c++ make
    
    #2、升级所有的包，防止出现版本过久不兼容问题
    yum -y update
    
    #centos7系统
    wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo

    #centos6系统
    wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS6-Base-163.repo
    
    #3、关闭防火墙 节点之前需要开放指定端口，为了方便，生产不要禁用
    #centos 6.x
    service iptables stop
    
    #centos 7.x
    systemctl stop firewalld.service
    
## 三、集群搭建

### 安装 Redis

    #1、下载，解压，编译安装
    cd /opt
    wget http://download.redis.io/releases/redis-4.0.1.tar.gz
    tar xzf redis-4.0.1.tar.gz
    cd redis-4.0.1
    make
    make test
    make install
    
    #2、如果因为上次编译失败，有残留的文件
    make distclean
    
### 创建节点


```
#批量替换
for i in {20001..20006} {20101..20106};do sed -i 's/10.1.1.116/10.1.1.119/g' redis_${i}.conf;done
```

    #1、首先在 192.168.56.11机器上 /opt/redis-4.0.1 目录下创建 redis-cluster 目录
    mkdir /opt/redis-4.0.1/redis-cluster
    
    #2、在 redis-cluster 目录下，创建名为7000、7001、7002的目录
    cd /opt/redis-4.0.1/redis-cluster
    mkdir 7000 7001 7002
    
    #3、分别修改这三个配置文件，把如下 redis.conf 配置内容粘贴进去
    vi 7000/redis.conf 
    vi 7001/redis.conf
    vi 7002/redis.conf
    
    #3.1、redis.conf 配置
    ##########################
    port 7000
    bind 192.168.56.11
    daemonize yes
    pidfile /var/run/redis_7000.pid
    cluster-enabled yes
    cluster-config-file nodes_7000.conf
    cluster-node-timeout 10100
    appendonly yes
    ##########################
    
    #3.2、redis.conf 配置说明
    ##########################
    #端口7000,7001,7002
    port 7000

    #默认ip为127.0.0.1，需要改为其他节点机器可访问的ip，否则创建集群时无法访问对应的端口，无法创建集群
    bind 192.168.56.11

    #redis后台运行
    daemonize yes

    #pidfile文件对应7000，7001，7002
    pidfile /var/run/redis_7000.pid

    #开启集群，把注释#去掉
    cluster-enabled yes

    #集群的配置，配置文件首次启动自动生成 7000，7001，7002          
    cluster-config-file nodes_7000.conf

    #请求超时，默认15秒，可自行设置 
    cluster-node-timeout 10100    

    #aof日志开启，有需要就开启，它会每次写操作都记录一条日志
    appendonly yes
    ##########################
    
    #4、接着在另外两台机器上(192.168.56.12，192.168.56.13)重复以上三步，对应的配置文件的IP修改下即可
    
## 五、启动集群

    #第一台机器上执行 3个节点
    for((i=0;i<=2;i++)); do /opt/redis-4.0.1/src/redis-server /opt/redis-4.0.1/redis-cluster/700$i/redis.conf; done

    #第二台机器上执行 3个节点
    for((i=0;i<=2;i++)); do /opt/redis-4.0.1/src/redis-server /opt/redis-4.0.1/redis-cluster/700$i/redis.conf; done

    #第三台机器上执行 3个节点 
    for((i=0;i<=2;i++)); do /opt/redis-4.0.1/src/redis-server /opt/redis-4.0.1/redis-cluster/700$i/redis.conf; done

## 六、检查服务

    #检查各 Redis 各个节点启动情况
    ps -ef | grep redis           //redis是否启动成功
    netstat -tnlp | grep redis    //监听redis端口

## 七、安装 Ruby

    yum -y install ruby ruby-devel rubygems rpm-build
    gem install redis
    
    #redis requires Ruby version >= 2.2.2的报错，查了资料发现是Centos默认支持ruby到2.0.0，可gem 安装redis需要最低是2.2.2

    解决办法是 先安装rvm，再把ruby版本提升至2.4.1

    1.安装curl

    sudo yum install curl

    2. 安装RVM

    #curl -L get.rvm.io | bash -s stable 
    
    #建议使用这个
    cd /usr/local/src/
    wget https://github.com/rvm/rvm/archive/1.29.4.tar.gz
    tar -zxvf 1.29.4.tar.gz
    cd /usr/local/src/rvm-1.29.4
    ./install

    3. 加载环境变量

    source /usr/local/rvm/scripts/rvm

    4. 查看rvm库中已知的ruby版本

    rvm list known

    5. 安装一个ruby版本

    rvm install 2.4.1

    6. 使用一个ruby版本

    rvm use 2.4.1

    7. 设置默认版本

    rvm remove 2.0.0

    8. 卸载一个已知版本

    ruby --version

    9. 再安装redis就可以了
    gem install redis

## 八、创建集群

### 注意：在任意一台上运行 不要在每台机器上都运行，一台就够了

    #Redis 官方提供了 redis-trib.rb 这个工具，就在解压目录的 src 目录中
    
    /opt/redis-4.0.1/src/redis-trib.rb create --replicas 1 192.168.56.11:7000 192.168.56.11:7001 192.168.56.11:7002 192.168.56.12:7000 192.168.56.12:7001 192.168.56.12:7002 192.168.56.13:7000 192.168.56.13:7001 192.168.56.13:7002
    
    #出现以下内容
    
    >>> Creating cluster
    >>> Performing hash slots allocation on 9 nodes...
    Using 4 masters:
    192.168.56.11:7000
    192.168.56.12:7000
    192.168.56.13:7000
    192.168.56.11:7001
    Adding replica 192.168.56.12:7001 to 192.168.56.11:7000
    Adding replica 192.168.56.13:7001 to 192.168.56.12:7000
    Adding replica 192.168.56.11:7002 to 192.168.56.13:7000
    Adding replica 192.168.56.12:7002 to 192.168.56.11:7001
    Adding replica 192.168.56.13:7002 to 192.168.56.11:7000
    M: 63f18edff5fe171aeaa174d2db0db1ef3712418d 192.168.56.11:7000
       slots:0-4095 (4096 slots) master
    M: 3e4169f8efbef7f934546201642f8f3ff3004952 192.168.56.11:7001
       slots:12288-16383 (4096 slots) master
    S: e3d5d25a05df142e2d2779420e5c6af6101ac942 192.168.56.11:7002
       replicates 830a4fed40f2db862949b7d8751d60f67b0dfcfc
    M: d5c62b4a22d9e332706a11da41ca24674e229f24 192.168.56.12:7000
       slots:4096-8191 (4096 slots) master
    S: 8b927473033827128faa20984c7d6ea98bfe1b0b 192.168.56.12:7001
       replicates 63f18edff5fe171aeaa174d2db0db1ef3712418d
    S: 2025636d2acd2e35525c14a5407b6e1487406718 192.168.56.12:7002
       replicates 3e4169f8efbef7f934546201642f8f3ff3004952
    M: 830a4fed40f2db862949b7d8751d60f67b0dfcfc 192.168.56.13:7000
       slots:8192-12287 (4096 slots) master
    S: d3bd52ec971b9f4831a990a07fe72e1c62e6e1aa 192.168.56.13:7001
       replicates d5c62b4a22d9e332706a11da41ca24674e229f24
    S: f75f71b130dd6233adff9a5633259306688a6e0e 192.168.56.13:7002
       replicates 63f18edff5fe171aeaa174d2db0db1ef3712418d
    Can I set the above configuration? (type 'yes' to accept): yes
    
    #输入 yes

    >>> Nodes configuration updated
    >>> Assign a different config epoch to each node
    >>> Sending CLUSTER MEET messages to join the cluster
    Waiting for the cluster to join..........
    >>> Performing Cluster Check (using node 192.168.56.11:7000)
    M: 63f18edff5fe171aeaa174d2db0db1ef3712418d 192.168.56.11:7000
       slots:0-4095 (4096 slots) master
       2 additional replica(s)
    S: 8b927473033827128faa20984c7d6ea98bfe1b0b 192.168.56.12:7001
       slots: (0 slots) slave
       replicates 63f18edff5fe171aeaa174d2db0db1ef3712418d
    S: e3d5d25a05df142e2d2779420e5c6af6101ac942 192.168.56.11:7002
       slots: (0 slots) slave
       replicates 830a4fed40f2db862949b7d8751d60f67b0dfcfc
    S: d3bd52ec971b9f4831a990a07fe72e1c62e6e1aa 192.168.56.13:7001
       slots: (0 slots) slave
       replicates d5c62b4a22d9e332706a11da41ca24674e229f24
    M: 3e4169f8efbef7f934546201642f8f3ff3004952 192.168.56.11:7001
       slots:12288-16383 (4096 slots) master
       1 additional replica(s)
    M: 830a4fed40f2db862949b7d8751d60f67b0dfcfc 192.168.56.13:7000
       slots:8192-12287 (4096 slots) master
       1 additional replica(s)
    S: 2025636d2acd2e35525c14a5407b6e1487406718 192.168.56.12:7002
       slots: (0 slots) slave
       replicates 3e4169f8efbef7f934546201642f8f3ff3004952
    M: d5c62b4a22d9e332706a11da41ca24674e229f24 192.168.56.12:7000
       slots:4096-8191 (4096 slots) master
       1 additional replica(s)
    S: f75f71b130dd6233adff9a5633259306688a6e0e 192.168.56.13:7002
       slots: (0 slots) slave
       replicates 63f18edff5fe171aeaa174d2db0db1ef3712418d
    [OK] All nodes agree about slots configuration.
    >>> Check for open slots...
    >>> Check slots coverage...
    [OK] All 16384 slots covered.
      
    
## 九、关闭集群

    #这样也可以，推荐
    pkill redis
    
    #循环节点逐个关闭
    for((i=0;i<=2;i++)); do /opt/redis-4.0.1/src/redis-cli -c -h 192.168.56.11 -p 700$i shutdown; done

    for((i=0;i<=2;i++)); do /opt/redis-4.0.1/src/redis-cli -c -h 192.168.56.12 -p 700$i shutdown; done

    for((i=0;i<=2;i++)); do /opt/redis-4.0.1/src/redis-cli -c -h 192.168.56.13 -p 700$i shutdown; done


## 十、集群验证

### 连接集群测试

    参数 -C 可连接到集群，因为 redis.conf 将 bind 改为了ip地址，所以 -h 参数不可以省略，-p 参数为端口号

    #1、我们在192.168.56.11机器redis 7000 的节点set 一个key
    
    [root@linux-node1 ~]# /opt/redis-4.0.1/src/redis-cli -h 192.168.56.11 -c -p 7000
    
    192.168.56.11:7000> set name www.ymq.io
    -> Redirected to slot [5798] located at 192.168.56.12:7000
    OK
    
    192.168.56.12:7000> get name
    "www.ymq.io"
    192.168.56.12:7000>
    
    发现redis set name 之后重定向到192.168.56.12机器 redis 7000 这个节点
    
    #2、我们在192.168.56.13机器redis 7000 的节点get一个key  
    
    [root@linux-node3 ~]# /opt/redis-4.0.1/src/redis-cli -h 192.168.56.13 -c -p 7000
    
    192.168.56.13:7000> get name
    -> Redirected to slot [5798] located at 192.168.56.12:7000
    "www.ymq.io"
    192.168.56.12:7000>
    
    发现redis get name 重定向到192.168.56.12机器 redis 7000 这个节点

    如果您看到这样的现象，说明集群已经是可用的了

### 检查集群状态

    /opt/redis-4.0.1/src/redis-trib.rb check 192.168.56.11:7000
    
    >>> Performing Cluster Check (using node 192.168.56.11:7000)
    M: 63f18edff5fe171aeaa174d2db0db1ef3712418d 192.168.56.11:7000
       slots:0-4095 (4096 slots) master
       2 additional replica(s)
    S: 8b927473033827128faa20984c7d6ea98bfe1b0b 192.168.56.12:7001
       slots: (0 slots) slave
       replicates 63f18edff5fe171aeaa174d2db0db1ef3712418d
    S: e3d5d25a05df142e2d2779420e5c6af6101ac942 192.168.56.11:7002
       slots: (0 slots) slave
       replicates 830a4fed40f2db862949b7d8751d60f67b0dfcfc
    S: d3bd52ec971b9f4831a990a07fe72e1c62e6e1aa 192.168.56.13:7001
       slots: (0 slots) slave
       replicates d5c62b4a22d9e332706a11da41ca24674e229f24
    M: 3e4169f8efbef7f934546201642f8f3ff3004952 192.168.56.11:7001
       slots:12288-16383 (4096 slots) master
       1 additional replica(s)
    M: 830a4fed40f2db862949b7d8751d60f67b0dfcfc 192.168.56.13:7000
       slots:8192-12287 (4096 slots) master
       1 additional replica(s)
    S: 2025636d2acd2e35525c14a5407b6e1487406718 192.168.56.12:7002
       slots: (0 slots) slave
       replicates 3e4169f8efbef7f934546201642f8f3ff3004952
    M: d5c62b4a22d9e332706a11da41ca24674e229f24 192.168.56.12:7000
       slots:4096-8191 (4096 slots) master
       1 additional replica(s)
    S: f75f71b130dd6233adff9a5633259306688a6e0e 192.168.56.13:7002
       slots: (0 slots) slave
       replicates 63f18edff5fe171aeaa174d2db0db1ef3712418d
    [OK] All nodes agree about slots configuration.
    >>> Check for open slots...
    >>> Check slots coverage...
    [OK] All 16384 slots covered.
    
### 修复数据

    [ERR] Node 10.33.56.11:7000 is not empty. Either the node already knows other nodes (check with CLUSTER NODES) or contains some key in database 0.
    
    #使用下面指令修复
    ./redis-trib.rb fix 10.33.56.11:7000
    
    https://blog.csdn.net/weixin_34050005/article/details/85980639   [ERR] Not all 16384 slots are covered by nodes.


### 列出集群节点

    列出集群当前已知的所有节点（node），以及这些节点的相关信息
    
    [root@linux-node1 ~]# /opt/redis-4.0.1/src/redis-cli -h 192.168.56.11 -c -p 7000
    
    192.168.56.11:7000> cluster nodes
    
    8b927473033827128faa20984c7d6ea98bfe1b0b 192.168.56.12:7001@17001 slave 63f18edff5fe171aeaa174d2db0db1ef3712418d 0 1539916347091 5 connected
    e3d5d25a05df142e2d2779420e5c6af6101ac942 192.168.56.11:7002@17002 slave 830a4fed40f2db862949b7d8751d60f67b0dfcfc 0 1539916347091 7 connected
    d3bd52ec971b9f4831a990a07fe72e1c62e6e1aa 192.168.56.13:7001@17001 slave d5c62b4a22d9e332706a11da41ca24674e229f24 0 1539916345031 8 connected
    3e4169f8efbef7f934546201642f8f3ff3004952 192.168.56.11:7001@17001 master - 0 1539916346074 2 connected 12288-16383
    830a4fed40f2db862949b7d8751d60f67b0dfcfc 192.168.56.13:7000@17000 master - 0 1539916346000 7 connected 8192-12287
    2025636d2acd2e35525c14a5407b6e1487406718 192.168.56.12:7002@17002 slave 3e4169f8efbef7f934546201642f8f3ff3004952 0 1539916346073 6 connected
    d5c62b4a22d9e332706a11da41ca24674e229f24 192.168.56.12:7000@17000 master - 0 1539916347092 4 connected 4096-8191
    f75f71b130dd6233adff9a5633259306688a6e0e 192.168.56.13:7002@17002 slave 63f18edff5fe171aeaa174d2db0db1ef3712418d 0 1539916346000 9 connected
    63f18edff5fe171aeaa174d2db0db1ef3712418d 192.168.56.11:7000@17000 myself,master - 0 1539916345000 1 connected 0-4095
    192.168.56.11:7000>

### 打印集群信息

    192.168.56.11:7000> cluster info
    cluster_state:ok
    cluster_slots_assigned:16384
    cluster_slots_ok:16384
    cluster_slots_pfail:0
    cluster_slots_fail:0
    cluster_known_nodes:9
    cluster_size:4
    cluster_current_epoch:9
    cluster_my_epoch:1
    cluster_stats_messages_ping_sent:940
    cluster_stats_messages_pong_sent:946
    cluster_stats_messages_sent:1886
    cluster_stats_messages_ping_received:938
    cluster_stats_messages_pong_received:940
    cluster_stats_messages_meet_received:8
    cluster_stats_messages_received:1886
    
## 集群命令

语法格式

    redis-cli -c -p port

集群

    cluster info ：打印集群的信息
    cluster nodes ：列出集群当前已知的所有节点（ node），以及这些节点的相关信息。

节点

    cluster meet <ip> <port> ：将 ip 和 port 所指定的节点添加到集群当中，让它成为集群的一份子。
    cluster forget <node_id> ：从集群中移除 node_id 指定的节点。
    cluster replicate <node_id> ：将当前节点设置为 node_id 指定的节点的从节点。
    cluster saveconfig ：将节点的配置文件保存到硬盘里面。
    
槽(slot)

    cluster addslots <slot> [slot ...] ：将一个或多个槽（ slot）指派（ assign）给当前节点。
    cluster delslots <slot> [slot ...] ：移除一个或多个槽对当前节点的指派。
    cluster flushslots ：移除指派给当前节点的所有槽，让当前节点变成一个没有指派任何槽的节点。
    cluster setslot <slot> node <node_id> ：将槽 slot 指派给 node_id 指定的节点，如果槽已经指派给另一个节点，那么先让另一个节点删除该槽>，然后再进行指派。
    cluster setslot <slot> migrating <node_id> ：将本节点的槽 slot 迁移到 node_id 指定的节点中。
    cluster setslot <slot> importing <node_id> ：从 node_id 指定的节点中导入槽 slot 到本节点。
    cluster setslot <slot> stable ：取消对槽 slot 的导入（ import）或者迁移（ migrate）。
    
键

    cluster keyslot <key> ：计算键 key 应该被放置在哪个槽上。
    cluster countkeysinslot <slot> ：返回槽 slot 目前包含的键值对数量。
    cluster getkeysinslot <slot> <count> ：返回 count 个 slot 槽中的键 。
    

参考文档：

https://blog.csdn.net/u010533511/article/details/89390387

https://blog.csdn.net/tianshi_rain/article/details/86612193  Redis5 cluster人工指定主从关系

https://www.centos.bz/2017/08/centos7-3-install-redis-4-0-1-cluster/

https://note.youdao.com/ynoteshare1/index.html?id=425c61744b4d4d24427e0dc4b44521ae&type=note  
