# 一、zookeeper安装

## 1、下载zookeeper安装包

```
cd /usr/local/src/
wget https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/zookeeper-3.4.14/zookeeper-3.4.14.tar.gz
```

## 2、安装zookeeper
```bash
#首先创建Zookeeper项目目录

mkdir -p /data0/zookeeper
cd /data0/zookeeper
mkdir zkdata
mkdir zkdatalog

cd /usr/local/src/
tar zxvf zookeeper-3.4.14.tar.gz
mv zookeeper-3.4.14/ /usr/local/zookeeper
cp -rf /usr/local/zookeeper/conf/zoo_sample.cfg /usr/local/zookeeper/conf/zoo.cfg

#zoo.cfg配置文件

cat > /usr/local/zookeeper/conf/zoo.cfg << \EOF
tickTime=10000
initLimit=10
syncLimit=5
dataDir=/data0/zookeeper/zkdata
dataLogDir=/data0/zookeeper/zkdatalog
clientPort=2181
EOF
```

## 3、服务启动
```bash
#服务启动
/usr/local/zookeeper/bin/zkServer.sh start /usr/local/zookeeper/conf/zoo.cfg

netstat -lutnp |grep java
tcp        0      0 0.0.0.0:2181  


#设置开机自启动
vim /etc/rc.local 添加：

/usr/local/zookeeper/bin/zkServer.sh start

#指定配置文件启动
/usr/local/zookeeper/bin/zkServer.sh start /usr/local/zookeeper/conf/zoo.cfg
```

## 4、检查状态
```bash
/usr/local/zookeeper/bin/zkServer.sh status /usr/local/zookeeper/conf/zoo.cfg

ZooKeeper JMX enabled by default
Using config: /usr/local/zookeeper/conf/zoo.cfg
Mode: leader
```

## 5、连接测试

```bash
/usr/local/zookeeper/bin/zkCli.sh -server 192.168.56.11:2181

#查看zookeeper的配置
echo conf | nc 127.0.0.1 2181

#查看哪个节点被选择作为follower或者leader
echo stat|nc 127.0.0.1 2181

```

# 二、kafka安装

## 1、下载kafka安装包
```
export VER="2.2.1"
cd /usr/local/src/
wget https://mirrors.tuna.tsinghua.edu.cn/apache/kafka/${VER}/kafka_2.12-${VER}.tgz
tar -zxvf kafka_2.12-${VER}.tgz
mv kafka_2.12-${VER} /usr/local/kafka
mkdir -p /usr/local/kafka/data/
```

## 2、修改文件server.properties
```bash
cat > /usr/local/kafka/config/server.properties<<\EOF
broker.id=1    # 唯一ID同一集群下broker.id不能重复
listeners=PLAINTEXT://localhost:9092   # 监听地址
log.dirs=/usr/local/kafka/data    # 数据目录
log.retention.hours=168   # kafka数据保留时间单位为hour 默认 168小时即 7天 
log.retention.bytes=1073741824  # (kafka数据量最大值，超出范围自动清理，和log.retention.hours 配合使用，注意其最大值设定不可超磁盘大小）
zookeeper.connect:192.168.56.11:2181 #(zookeeper连接ip及port,多个以逗号分隔)
offsets.topic.replication.factor=1 #topic的offset的备份数，建议设置更高的数字保证更高的可用性
EOF

#注意不能有注释
cat > /usr/local/kafka/config/server.properties<<\EOF
broker.id=1
listeners=PLAINTEXT://localhost:9092
log.dirs=/usr/local/kafka/data
log.retention.hours=168
log.retention.bytes=1073741824
zookeeper.connect:192.168.56.11:2181
offsets.topic.replication.factor=1
EOF
```

## 3、启动和停止
```
#启动
cd /usr/local/kafka/
nohup ./bin/kafka-server-start.sh config/server.properties &

#停止
cd /usr/local/kafka/
./bin/kafka-server-stop.sh
```

## 4、创建topic
```bash
创建topic:
bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic test

展示topic:
bin/kafka-topics.sh --list --zookeeper localhost:2181

生产者：
bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test

消费者：
bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --from-beginning
```



参考资料：

https://segmentfault.com/a/1190000009983727

https://www.cnblogs.com/wonglu/p/8687488.html  Kafka单机配置部署
