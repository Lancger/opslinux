# 一、zookeeper部署
```
docker pull zookeeper
docker run -d --name=my_zookeeper --restart=always -p 2181:2181 zookeeper:latest
docker logs -f my_zookeeper

#使用 ZK 命令行客户端连接 ZK
docker run -it --rm --link my_zookeeper:zookeeper zookeeper zkCli.sh -server zookeeper
```

# 二、安装docker-compose
```
export Version="1.24.0"

curl -L "https://github.com/docker/compose/releases/download/${Version}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose

docker-compose --version
```

# 三、
```bash
1、启动zookeeper

docker run -d --name zookeeper --restart always -p 2181 -t wurstmeister/zookeeper

2、启动kafka

docker run -d --name kafka --restart always -p 9092:9092 --link zookeeper --env KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181 --env KAFKA_ADVERTISED_HOST_NAME=127.0.0.1 --env KAFKA_ADVERTISED_PORT=9092 --volume /etc/localtime:/etc/localtime wurstmeister/kafka:latest

3、启动kafka管理工具

docker run -itd \
--restart=always \
--name=kafka-manager \
-p 9000:9000 \
-e ZK_HOSTS="192.168.56.11:2181" \
sheepkiller/kafka-manager

4、查看docker端口
root># docker port fe73af90eff1
9000/tcp -> 0.0.0.0:9000

```

# 四、docker-compose运行单机版kafka
```
cat > docker-compose.yml <<-EOF
version: '2'
services:
  zookeeper:
    image: wurstmeister/zookeeper   ## 镜像
    ports:
      - "2181:2181"                 ## 对外暴露的端口号
  kafka:
    image: wurstmeister/kafka       ## 镜像
    volumes: 
        - /etc/localtime:/etc/localtime ## 挂载位置（kafka镜像和宿主机器之间时间保持一直）
    ports:
      - "9092:9092"
    environment:
      KAFKA_ADVERTISED_HOST_NAME: 192.168.56.11     ## 修改:宿主机IP
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181       ## 卡夫卡运行是基于zookeeper的
  kafka-manager:  
    image: sheepkiller/kafka-manager                ## 镜像：开源的web管理kafka集群的界面
    environment:
        ZK_HOSTS: 192.168.56.11                     ## 修改:宿主机IP
    ports:  
      - "9000:9000"                                 ## 暴露端口
EOF

docker-compose up -d
```

# 五、docker-compose运行集群版kafka
```
/*  运行kafka集群模式*/
/*  由于指定了kafka对外暴露的端口号，增加集群节点会报端口冲突的错误，请将kafka暴露的端口号删掉后再执行如下命令*/
/*  自己指定kafka的节点数量 */

1、先运行单机版kafka

cat > docker-compose.yml <<-EOF
version: '2'
services:
  zookeeper:
    image: wurstmeister/zookeeper   ## 镜像
    ports:
      - "2181:2181"                 ## 对外暴露的端口号
  kafka:
    image: wurstmeister/kafka       ## 镜像
    volumes: 
        - /etc/localtime:/etc/localtime ## 挂载位置（kafka镜像和宿主机器之间时间保持一直）
    environment:
      KAFKA_ADVERTISED_HOST_NAME: 192.168.56.11     ## 修改:宿主机IP
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181       ## 卡夫卡运行是基于zookeeper的
  kafka-manager:  
    image: sheepkiller/kafka-manager                ## 镜像：开源的web管理kafka集群的界面
    environment:
        ZK_HOSTS: 192.168.56.11                     ## 修改:宿主机IP
    ports:  
      - "9000:9000"                                 ## 暴露端口
EOF

docker-compose up -d

2、指定kafka的节点数量
docker-compose scale kafka=3
```

# 六、测试发送消息
```
1、创建一个主题

bin/kafka-topics.sh --create --zookeeper zookeeper:2181 --replication-factor 1 --partitions 1 --topic mykafka


2、运行一个消生产者，指定topic为刚刚创建的主题

bin/kafka-console-producer.sh --broker-list localhost:9092 --topic mykafka 

3、运行一个消费者，指定同样的主题

bin/kafka-console-consumer.sh --zookeeper zookeeper:2181 --topic mykafka --from-beginning 

这时在生产者输入测试消息，在消费者就可以接收消息了

```

参考资料：

https://www.jianshu.com/p/240d9166aaaf   Docker容器安装单机Kafka

https://johng.cn/install-kafka-with-docker/

https://www.cnblogs.com/wonglu/p/8687488.html   Kafka单机配置部署

https://www.jianshu.com/p/2425b9b34165  Kafka安装启动入门教程
