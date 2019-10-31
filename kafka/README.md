# 一、安装docker-compose
```bash
export Version="1.24.0"
curl -L "https://github.com/docker/compose/releases/download/${Version}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version

# 删除所有容器 
docker rm -f `docker ps -a -q`
```

# 二、docker安装zk和kafka

1、启动zookeeper
```bash
docker run -d --name my_zookeeper --restart always -p 2181:2181 -t wurstmeister/zookeeper

#使用 ZK 命令行客户端连接 ZK
docker run -it --rm --link my_zookeeper:zookeeper zookeeper zkCli.sh -server zookeeper

#这个命令的含义是:
    #1、启动一个 zookeeper 镜像, 并运行这个镜像内的 zkCli.sh 命令, 命令参数是 "-server zookeeper"
    #2、将我们先前启动的名为 zookeeper 的容器连接(link) 到我们新建的这个容器上, 并将其主机名命名为 zookeeper
    #3、当我们执行了这个命令后, 就可以像正常使用 ZK 命令行客户端一样操作 ZK 服务了.
```

2、启动kafka

`docker run -d --name kafka --restart always -p 9092:9092 --link my_zookeeper:zookeeper --env KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181 --env KAFKA_ADVERTISED_HOST_NAME=192.168.56.11 --env KAFKA_ADVERTISED_PORT=9092 --volume /etc/localtime:/etc/localtime wurstmeister/kafka:latest`

3、启动kafka管理工具
```
docker run -itd \
--restart=always \
--name=kafka-manager \
-p 9000:9000 \
-e ZK_HOSTS="192.168.56.11:2181" \
sheepkiller/kafka-manager
```

4、查看docker端口
```
root># docker port fe73af90eff1
9000/tcp -> 0.0.0.0:9000
```

5、访问kafka-manager
`http://192.168.56.11:9000/`
```

# 三、测试发送消息
```
1、登录的容器内部
root># docker exec -it kafka /bin/bash

bash-4.4# cd /opt/kafka_2.12-2.3.0/

2、创建一个主题
/opt/kafka/bin/kafka-topics.sh --create --zookeeper zookeeper:2181 --replication-factor 1 --partitions 1 --topic my-test

Created topic my-test.

3、查看topic列表
/opt/kafka/bin/kafka-topics.sh --list --zookeeper zookeeper:2181

4、运行一个消生产者，指定topic为刚刚创建的主题（发送消息）
/opt/kafka/bin/kafka-console-producer.sh --broker-list localhost:9092 --topic my-test

5、运行一个消费者，指定同样的主题
/opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic my-test --from-beginning

这时在生产者输入测试消息，在消费者就可以接收消息了
```

# 四、docker-compose运行单机版kafka
```
docker rm -f `docker ps -a -q`

cat > docker-compose.yml <<-EOF
version: '2'
services:
  zookeeper:
    image: wurstmeister/zookeeper   ## 镜像
    restart: always
    container_name: zookeeper
    ports:
      - "2181:2181"                 ## 对外暴露的端口号
  kafka:
    image: wurstmeister/kafka       ## 镜像
    restart: always
    container_name: kafka
    volumes: 
        - /etc/localtime:/etc/localtime  ## 挂载位置（kafka镜像和宿主机器之间时间保持一直）
    ports:
      - "9092:9092"
    environment:
      KAFKA_ADVERTISED_HOST_NAME: 192.168.56.11     ## 修改:宿主机IP
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181       ## 卡夫卡运行是基于zookeeper的
  kafka-manager:  
    image: sheepkiller/kafka-manager                ## 镜像：开源的web管理kafka集群的界面
    restart: always
    container_name: kafka-manager
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

docker rm -f `docker ps -a -q`

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

# 六、多个broker+多个zookeeper的kafka集群
```
docker rm -f `docker ps -a -q`

cat > docker-compose.yml <<-EOF
version: '2'
services:
    zoo1:
        image: zookeeper
        restart: always
        container_name: zoo1
        ports:
            - "2181:2181"
        environment:
            ZOO_MY_ID: 1
            ZOO_SERVERS: server.1=zoo1:2888:3888 server.2=zoo2:2888:3888 server.3=zoo3:2888:3888 server.4=zoo4:2888:3888:observer

    zoo2:
        image: zookeeper
        restart: always
        container_name: zoo2
        ports:
            - "2182:2181"
        environment:
            ZOO_MY_ID: 2
            ZOO_SERVERS: server.1=zoo1:2888:3888 server.2=zoo2:2888:3888 server.3=zoo3:2888:3888 server.4=zoo4:2888:3888:observer

    zoo3:
        image: zookeeper
        restart: always
        container_name: zoo3
        ports:
            - "2183:2181"
        environment:
            ZOO_MY_ID: 3
            ZOO_SERVERS: server.1=zoo1:2888:3888 server.2=zoo2:2888:3888 server.3=zoo3:2888:3888 server.4=zoo4:2888:3888:observer
    zoo4:
        image: zookeeper
        restart: always
        container_name: zoo4
        ports:
            - "2184:2181"
        environment:
            ZOO_MY_ID: 4
            PEER_TYPE: observer
            ZOO_SERVERS: server.1=zoo1:2888:3888 server.2=zoo2:2888:3888 server.3=zoo3:2888:3888 server.4=zoo4:2888:388:observer

    broker1:
        image: wurstmeister/kafka
        restart: always
        container_name: broker1
        ports:
          - "9091:9092"
        depends_on:
          - zoo1
          - zoo2
          - zoo3
          - zoo4
        environment:
          KAFKA_BROKER_ID: 1
          KAFKA_ADVERTISED_HOST_NAME: broker1
          KAFKA_ADVERTISED_PORT: 9092
          KAFKA_HOST_NAME: broker1
          KAFKA_ZOOKEEPER_CONNECT: zoo1:2181,zoo2:2181,zoo3:2181,zoo4:2181
          KAFKA_LISTENERS: PLAINTEXT://broker1:9092
          KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://broker1:9092

    broker2:
        image: wurstmeister/kafka
        restart: always
        container_name: broker2
        ports:
          - "9092:9092"
        depends_on:
          - zoo1
          - zoo2
          - zoo3
          - zoo4
        environment:
          KAFKA_BROKER_ID: 2
          KAFKA_ADVERTISED_HOST_NAME: broker2
          KAFKA_ADVERTISED_PORT: 9092
          KAFKA_HOST_NAME: broker2
          KAFKA_ZOOKEEPER_CONNECT: zoo1:2181,zoo2:2181,zoo3:2181,zoo4:2181
          KAFKA_LISTENERS: PLAINTEXT://broker2:9092
          KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://broker2:9092

    broker3:
        image: wurstmeister/kafka
        restart: always
        container_name: broker3
        ports:
          - "9093:9092"
        depends_on:
          - zoo1
          - zoo2
          - zoo3
          - zoo4
        environment:
          KAFKA_BROKER_ID: 3
          KAFKA_ADVERTISED_HOST_NAME: broker3
          KAFKA_ADVERTISED_PORT: 9092
          KAFKA_HOST_NAME: broker3
          KAFKA_ZOOKEEPER_CONNECT: zoo1:2181,zoo2:2181,zoo3:2181,zoo4:2181
          KAFKA_LISTENERS: PLAINTEXT://broker3:9092
          KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://broker3:9092
EOF

docker-compose up -d


https://www.cnblogs.com/yingww/p/9188701.html   docker下部署kafka集群(多个broker+多个zookeeper)
```

# 七、问题
```
1、修复问题
Yikes! Ask timed out on [ActorSelection[Anchor(akka://kafka-manager-system/), Path(/user/kafka-manager)]] after [5000 ms]

原因为连接不上zookeeper报错导致

```

参考资料：

https://www.cnblogs.com/yingww/p/9188701.html  docker下部署kafka集群(多个broker+多个zookeeper)

https://www.jianshu.com/p/240d9166aaaf   Docker容器安装单机Kafka

https://johng.cn/install-kafka-with-docker/

https://www.cnblogs.com/wonglu/p/8687488.html   Kafka单机配置部署

https://www.jianshu.com/p/2425b9b34165  Kafka安装启动入门教程

https://www.cnblogs.com/hongdada/p/8117677.html  ZooKeeper 增加Observer部署模式提高性能

