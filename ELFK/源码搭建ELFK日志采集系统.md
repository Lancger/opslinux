# 一、软件包下载
```
cd /usr/local/src/

export version="7.2.0"
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${version}-linux-x86_64.tar.gz
wget https://artifacts.elastic.co/downloads/kibana/kibana-${version}-linux-x86_64.tar.gz
wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-${version}-linux-x86_64.tar.gz
```
# 二、配置Elasticsearch实现冷热数据分离

为了不浪费服务器资源（每台机器上均配置有SSD和大存储,且内存配置较高），提高ES读写性能，我们尝试进行了ES集群冷热分离的配置。四台机器，均配置有SSD和SATA盘。每台机器上运行两个ES实例，其中一个实例为配置data目录为SSD

1、默认情况下，每个节点都有成为主节点的资格，也会存储数据，还会处理客户端的请求。    

2、在一个生产集群中我们可以对这些节点的职责进行划分。建议集群中设置3台以上的节点作为master节点【node.master: true node.data: false】，这些节点只负责成为主节点，维护整个集群的状态。           

3、再根据数据量设置一批data节点【node.master: false node.data: true】，这些节点只负责存储数据，后期提供建立索引和查询索引的服务，这样的话如果用户请求比较频繁，这些节点的压力也会比较大。     

4、在集群中建议再设置一批client节点【node.master: false node.data: true】，这些节点只负责处理用户请求，实现请求转发，负载均衡等功能。          

5、master节点：普通服务器即可(CPU 内存 消耗一般)。         

data节点：主要消耗磁盘，内存。            

client节点：普通服务器即可(如果要进行分组聚合操作的话，建议这个节点内存也分配多一点)。

  ![elasticsearch冷热架构](https://github.com/Lancger/opslinux/blob/master/images/es-hot-cold.png)

```
SSD  热数据
SATA 冷数据
```
| 服务器名称         | 端口            | 节点名称     |  磁盘类型  |  存储数据  |                    角色                  |
| ---------------- |:---------------:| :---------:| :--------:| :--------:| ---------------------------------------:|
| server-01        | 9300            | es-master1  |   SATA   |  元数据    | filebeat+es_master+kafka+zookeeper      |
| server-02        | 9300            | es-master2  |   SATA   |  元数据    | filebeat+es_master+kafka+zookeeper      |
| server-03        | 9300            | es-master3  |   SATA   |  元数据    | filebeat+es_master+kafka+zookeeper      |
| server-01        | 9301            | es-hot1     |   SSD    |  HOT      | es_data_node                            |
| server-02        | 9301            | es-hot2     |   SSD    |  HOT      | es_data_node                            |
| server-03        | 9301            | es-hot3     |   SSD    |  HOT      | es_data_node                            |
| server-04        | 9300            | es-cold1    |   SATA   |  COLD     | filebeat+es_data_node+kibana            |
| server-04        | 9301            | es-cold2    |   SATA   |  COLD     | es_data_node                            |


# 三、准备Elasticsearch

1、安装Java环境
```
#yum安装
yum -y install java-1.8.0-openjdk

#源码安装
java   http://www.oracle.com/technetwork/java/javase/downloads/index.html 

tar -zxvf jdk-8u201-linux-x64.tar.gz -C /opt/

#Set JAVA_HOME
export JAVA_HOME=/opt/jdk1.8.0_201
export PATH=$JAVA_HOME/bin:$PATH
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar

使环境变量生效
source /etc/profile

验证安装是否成功
java -version
```


2、新增用户和系统配置
```
0、主机hosts绑定
cat > /etc/hosts <<EOF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
10.1.5.112 server-01
10.1.5.116 server-02
10.1.5.117 server-03
10.1.5.120 server-04
EOF

1、新增用户和解压安装包
chattr -i /etc/passwd* && chattr -i /etc/group* && chattr -i /etc/shadow* && chattr -i /etc/gshadow*
groupadd elk
useradd -g elk elk
mkdir -p /usr/local/elk/

tar -zxvf elasticsearch-${version}-linux-x86_64.tar.gz -C /usr/local/elk
cd /usr/local/elk
mv elasticsearch-${version} elasticsearch        #master实例
cp -rf elasticsearch elasticsearch-hot      #热数据es实例
cp -rf elasticsearch elasticsearch-cold     #冷数据es实例
chown -R elk:elk /usr/local/elk/

2、增加vm.max_map_count项到sysctl.conf文件中
a、修改配置文件方式
vim /etc/sysctl.conf
vm.max_map_count = 655360
sysctl -p

b、命令行方式
sysctl -w vm.max_map_count=655360
sysctl -a | grep vm.max_map_count

3、修改用户文件最大数量
vim /etc/security/limits.conf 
elk        hard    nofile           262144
elk        soft    nofile           262144

4、修改内存限制
vim /etc/security/limits.conf
# allow user 'elk' mlockall
elk soft memlock unlimited
elk hard memlock unlimited
```

3、修改配置文件
```
#创建热数据存放目录
mkdir -p /data0/database/elasticsearch-hot/ /data1/database/elasticsearch-hot/

#创建冷数据存放目录
mkdir -p /data0/database/elasticsearch-cold/ /data1/database/elasticsearch-cold/

chown -R elk:elk /data0/database/ /data1/database/
```
master节点配置
```
3个master节点只需要替换下面配置即可

node.name: es-master1    #配置节点名称
node.name: es-master2    #配置节点名称
node.name: es-master3    #配置节点名称
```
元数据节点配置
```
cat << EOF > /usr/local/elk/elasticsearch/config/elasticsearch.yml
cluster.name: Demo-Cloud  #配置集群名称
node.name: es-master1  #配置节点名称
#node.attr.box_type: hot  #node.attr.box_type: hot热数据节点，node.attr.box_type: cold 冷数据节点
node.max_local_storage_nodes: 2  #允许每个机器启动两个es进程
node.master: true  #指定该节点是否有资格被选举成为node，默认是true，es是默认集群中的第一台机器为master，如果这台机挂了就会重新选举master。
node.data: false  #指定该节点是否存储索引数据，默认为true。
#index.number_of_shards: 5  #设置默认索引分片个数，默认为5片。
#index.number_of_replicas: 1  #设置默认索引副本个数，默认为1个副本。
path.data: /data/database/elasticsearch/,/data1/database/elasticsearch/  #配置data存放的路径，磁盘为ssd磁盘
path.logs: /usr/local/elk/elasticsearch/logs  #配置日志存放的路径
bootstrap.memory_lock: false  #配置是否使用内存交换分区
bootstrap.system_call_filter: false  #配置是否启用检测
http.max_content_length: 1000mb  #设置内容的最大容量，默认100mb
http.enabled: false  #是否使用http协议对外提供服务，默认为true，开启。
gateway.type: local  #gateway的类型，默认为local即为本地文件系统，可以设置为本地文件系统，分布式文件系统，hadoop的HDFS，和amazon的s3服务器等。
gateway.recover_after_nodes: 1  #设置集群中N个节点启动时进行数据恢复，默认为1。
network.host: 0.0.0.0  #配置监听地址
http.port: 9200  #配置监听端口
transport.tcp.port: 9300  #设置节点之间交互的tcp端口，默认是9300。
discovery.zen.ping.timeout: 3s  #设置集群中自动发现其它节点时ping连接超时时间，默认为3秒，对于比较差的网络环境可以高点的值来防止自动发现时出错。
discovery.zen.ping.multicast.enabled: false  #配置是否启用广播地址
discovery.zen.ping.unicast.hosts: ["server-01:9300", "server-01:9301", "server-02:9300", "server-02:9301", "server-03:9300", "server-03:9301", "server-04:9300", "server-04:9301"]  #配置指定节点
EOF
```
热数据节点配置
```
cat << EOF > /usr/local/elk/elasticsearch-hot/config/elasticsearch.yml
cluster.name: Demo-Cloud  #配置集群名称
node.name: es-hot1  #配置节点名称
node.attr.box_type: hot  #node.attr.box_type: hot热数据节点，node.attr.box_type: cold 冷数据节点
node.max_local_storage_nodes: 2  #允许每个机器启动两个es进程
node.master: false  #指定该节点是否有资格被选举成为node，默认是true，es是默认集群中的第一台机器为master，如果这台机挂了就会重新选举master。
node.data: true  #指定该节点是否存储索引数据，默认为true。
index.number_of_shards: 5  #设置默认索引分片个数，默认为5片。
index.number_of_replicas: 1  #设置默认索引副本个数，默认为1个副本。
path.data: /data/database/elasticsearch/,/data1/database/elasticsearch/  #配置data存放的路径，磁盘为ssd磁盘
path.logs: /usr/local/elk/elasticsearch-hot/logs  #配置日志存放的路径
bootstrap.memory_lock: false  #配置是否使用内存交换分区
bootstrap.system_call_filter: false  #配置是否启用检测
http.max_content_length: 1000mb  #设置内容的最大容量，默认100mb
http.enabled: false  #是否使用http协议对外提供服务，默认为true，开启。
gateway.type: local  #gateway的类型，默认为local即为本地文件系统，可以设置为本地文件系统，分布式文件系统，hadoop的HDFS，和amazon的s3服务器等。
gateway.recover_after_nodes: 1  #设置集群中N个节点启动时进行数据恢复，默认为1。
network.host: 0.0.0.0  #配置监听地址
http.port: 9200  #配置监听端口
transport.tcp.port: 9300  #设置节点之间交互的tcp端口，默认是9300。
discovery.zen.ping.timeout: 3s  #设置集群中自动发现其它节点时ping连接超时时间，默认为3秒，对于比较差的网络环境可以高点的值来防止自动发现时出错。
discovery.zen.ping.multicast.enabled: false  #配置是否启用广播地址
discovery.zen.ping.unicast.hosts: ["server-01:9300", "server-01:9301", "server-02:9300", "server-02:9301", "server-03:9300", "server-03:9301", "server-04:9300", "server-04:9301"]  #配置指定节点
EOF
```
冷数据节点配置
```
cat << EOF > /usr/local/elk/elasticsearch-hot/config/elasticsearch.yml
cluster.name: Demo-Cloud  #配置集群名称
node.name: es-cold1  #配置节点名称
node.attr.box_type: cold  #node.attr.box_type: hot热数据节点，node.attr.box_type: cold 冷数据节点
node.max_local_storage_nodes: 2  #允许每个机器启动两个es进程
node.master: false  #指定该节点是否有资格被选举成为node，默认是true，es是默认集群中的第一台机器为master，如果这台机挂了就会重新选举master。
node.data: true  #指定该节点是否存储索引数据，默认为true。
index.number_of_shards: 5  #设置默认索引分片个数，默认为5片。
index.number_of_replicas: 1  #设置默认索引副本个数，默认为1个副本。
path.data: /data/database/elasticsearch/,/data1/database/elasticsearch/  #配置data存放的路径，磁盘为ssd磁盘
path.logs: /usr/local/elk/elasticsearch-cold/logs  #配置日志存放的路径
bootstrap.memory_lock: false  #配置是否使用内存交换分区
bootstrap.system_call_filter: false  #配置是否启用检测
http.max_content_length: 1000mb  #设置内容的最大容量，默认100mb
http.enabled: false  #是否使用http协议对外提供服务，默认为true，开启。
gateway.type: local  #gateway的类型，默认为local即为本地文件系统，可以设置为本地文件系统，分布式文件系统，hadoop的HDFS，和amazon的s3服务器等。
gateway.recover_after_nodes: 1  #设置集群中N个节点启动时进行数据恢复，默认为1。
network.host: 0.0.0.0  #配置监听地址
http.port: 9200  #配置监听端口
transport.tcp.port: 9300  #设置节点之间交互的tcp端口，默认是9300。
discovery.zen.ping.timeout: 3s  #设置集群中自动发现其它节点时ping连接超时时间，默认为3秒，对于比较差的网络环境可以高点的值来防止自动发现时出错。
discovery.zen.ping.multicast.enabled: false  #配置是否启用广播地址
discovery.zen.ping.unicast.hosts: ["server-01:9300", "server-01:9301", "server-02:9300", "server-02:9301", "server-03:9300", "server-03:9301", "server-04:9300", "server-04:9301"]  #配置指定节点
EOF
```
4、启动elasticsearch
```
su - elk

/usr/local/elk/elasticsearch/bin/elasticsearch
```

# 三、准备Filebeat


参考文档

https://segmentfault.com/a/1190000016112645  简单的通过源码安装 elk 平台 

http://www.mamicode.com/info-detail-2361555.html    elasticsearch实现冷热数据分离

https://blog.csdn.net/J_bean/article/details/80147277   

https://blog.51cto.com/stuart/2335120  

https://segmentfault.com/q/1010000005778903  github上的markdown如何书写表格？ 

