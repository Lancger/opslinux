## Docker多机器部署Zookeeper集群
```
本示例基于Centos 7，在阿里云的三台机器上部署zookeeper集群，假设目前使用的账号为www，拥有sudo权限。

由于Docker官方镜像下载较慢，可以开启阿里云的Docker镜像下载加速器，可参考此文进行配置---https://www.cnblogs.com/atuotuo/p/6264800.html
```

假设三台主机的ip分别为：
```
主机一：192.168.0.1
主机二：192.168.0.2
主机三：192.168.0.3
```
三台主机的安装步骤相似，以主机一为例：

1. 安装docker服务:
```
sudo yum install -y docker
```
 
2. 启动docker服务: 
```
sudo service docker start
```
 
3. 查找zookeeper镜像：
```
sudo docker search zookeeper
```
 
4. 下载官方zookeeper镜像：
```
#默认最新版本
sudo  docker pull docker.io/zookeeper

#下载指定版本
sudo  docker pull docker.io/zookeeper:3.4.14
```

5. 下载完后可检查镜像：
```
sudo docker images 
```

6. 主机上建立挂载目录和zookeeper配置文件：
```
mkdir -p /data0/zookeeper_data/conf
mkdir -p /data0/zookeeper_data/data
cd /data0/zookeeper_data/conf
touch zoo.cfg

三台主机上的zoo.cfg配置信息如下:

cat > zoo.cfg << \EOF
clientPort=2181
dataDir=/data
dataLogDir=/data/log
tickTime=2000
initLimit=5
syncLimit=2
autopurge.snapRetainCount=3
autopurge.purgeInterval=0
maxClientCnxns=60
server.0=172.33.0.16:2888:3888
server.1=172.33.0.13:2888:3888
server.2=172.33.0.10:2888:3888
EOF

在主机一上为自己分配server id，命令如下：

cd /data0/zookeeper_data/data
touch myid
echo 0 > myid

在主机二上为自己分配server id，命令如下：

cd /data0/zookeeper_data/data
touch myid
echo 1 > myid

在主机三上为自己分配server id，命令如下：

cd /data0/zookeeper_data/data
touch myid
echo 2 > myid
```

7. 三台主机依次启动容器：
```
docker rm -f `docker ps -a -q` 

sudo docker run --network host -v /data0/zookeeper_data/data:/data:rw -v /data0/zookeeper_data/conf:/conf:rw --privileged=true --name zk-2181 -d docker.io/zookeeper:3.4.14

docker ps -a

命令说明：

--network host: 使用主机上的网络配置，如果不用这种模式，而用默认的bridge模式，会导致容器跨主机间通信失败
-v /data0/zookeeper_data/data:/data：主机的数据目录挂载到容器/data下
-v /data0/zookeeper_data/conf:/conf： 主机的配置目录挂载到容器的/conf下，容器内的zkServer.sh默认会读取/conf/zoo.cfg下的配置

都启动完成后，每台主机的2181/2888/3888端口都会开放出来了
```

8. 检查容器的启动情况：
```
sudo docker exec -it 容器id /bin/bash

进入容器内部后，其工作目录为：/zookeeper-3.4.13（版本依据镜像而定），执行zookeeper检查：

[www@sh-lbs02 data]$ sudo docker exec -it 456 /bin/bash
[sudo] password for release: 
bash-4.4# pwd
/zookeeper-3.4.13
bash-4.4# zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /conf/zoo.cfg
Mode: follower
bash-4.4# 

可以看到这个容器目前为从机状态，至此集群已启动完成。
```

9. 若启动失败了，通过如下命令观察zookeeper的启动日志：
```
sudo docker logs 容器id/容器名称

内容示例如下：

[release@sh-lbs02 ~]$ sudo docker logs zk-2181
ZooKeeper JMX enabled by default
Using config: /conf/zoo.cfg
log4j:WARN No appenders could be found for logger (org.apache.zookeeper.server.quorum.QuorumPeerConfig).
log4j:WARN Please initialize the log4j system properly.
log4j:WARN See http://logging.apache.org/log4j/1.2/faq.html#noconfig for more info.

```

10.检查zk角色
```
yum install nc -y

#节点一(该节点为leader)
echo stat | nc 127.0.0.1 2181

Zookeeper version: 3.4.14-4c25d480e66aadd371de8bd2fd8da255ac140bcf, built on 03/06/2019 16:18 GMT
Clients:
 /127.0.0.1:64123[0](queued=0,recved=1,sent=0)

Latency min/avg/max: 0/0/0
Received: 1
Sent: 0
Connections: 1
Outstanding: 0
Zxid: 0x200000000
Mode: leader
Node count: 4
Proposal sizes last/min/max: -1/-1/-1

#节点二
echo stat | nc 127.0.0.1 2181

Zookeeper version: 3.4.14-4c25d480e66aadd371de8bd2fd8da255ac140bcf, built on 03/06/2019 16:18 GMT
Clients:
 /127.0.0.1:58931[0](queued=0,recved=1,sent=0)

Latency min/avg/max: 0/0/0
Received: 1
Sent: 0
Connections: 1
Outstanding: 0
Zxid: 0x0
Mode: follower
Node count: 4

#节点三
echo stat | nc 127.0.0.1 2181

Zookeeper version: 3.4.14-4c25d480e66aadd371de8bd2fd8da255ac140bcf, built on 03/06/2019 16:18 GMT
Clients:
 /127.0.0.1:58931[0](queued=0,recved=1,sent=0)

Latency min/avg/max: 0/0/0
Received: 1
Sent: 0
Connections: 1
Outstanding: 0
Zxid: 0x0
Mode: follower
Node count: 4
```

11.docker跑zk客户端测试
```
docker run -it --rm zookeeper zkCli.sh -server 172.33.0.16:2181,172.33.0.13:2181,172.33.0.10:2181

[zk: 172.33.0.16:2181,172.33.0.13:2181,172.33.0.10:2181(CONNECTED) 1] ls  /
[zookeeper]
[zk: 172.33.0.16:2181,172.33.0.13:2181,172.33.0.10:2181(CONNECTED) 2] get zookeeper
Path must start with / character
[zk: 172.33.0.16:2181,172.33.0.13:2181,172.33.0.10:2181(CONNECTED) 3] create /zk myData
Created /zk
[zk: 172.33.0.16:2181,172.33.0.13:2181,172.33.0.10:2181(CONNECTED) 4] ls /
[zk, zookeeper]
[zk: 172.33.0.16:2181,172.33.0.13:2181,172.33.0.10:2181(CONNECTED) 5] get /zk
myData
```
参考资料：

https://www.cnblogs.com/hutao722/p/9668023.html Docker应用系列（二）| 构建Zookeeper集群   
