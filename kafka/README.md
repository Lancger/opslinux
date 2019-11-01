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
#启动 ZK 服务端
docker run -d --name my_zookeeper --restart always -p 2181:2181 -t wurstmeister/zookeeper

#使用 ZK 命令行客户端连接 ZK
docker run -it --rm --link my_zookeeper:zookeeper zookeeper zkCli.sh -server zookeeper

#这个命令的含义是:
    #1、启动一个 zookeeper 镜像, 并运行这个镜像内的 zkCli.sh 命令, 命令参数是 "-server zookeeper"
    #2、将我们先前启动的名为 zookeeper 的容器连接(link) 到我们新建的这个容器上, 并将其主机名命名为 zookeeper
    #3、当我们执行了这个命令后, 就可以像正常使用 ZK 命令行客户端一样操作 ZK 服务了.
```

2、启动kafka
```
docker run -d --name kafka --restart always -p 9092:9092 --link my_zookeeper:zookeeper --env KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181 --env KAFKA_ADVERTISED_HOST_NAME=192.168.56.11 --env KAFKA_ADVERTISED_PORT=9092 --volume /etc/localtime:/etc/localtime wurstmeister/kafka:latest
```

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
root># docker port kafka-manager
9000/tcp -> 0.0.0.0:9000
```

5、访问kafka-manager
```
http://192.168.56.11:9000/
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

1、清理集群

```
docker rm -f `docker ps -a -q`
```

2、#新建docker网络
```
docker network create zoo_kafka
docker network ls
```

3、#创建zookeeper集群
```bash
cat > docker-compose-zk.yml <<-EOF
version: '2'
services:
  zoo1:
    image: zookeeper:3.4 # 镜像名称
    restart: always # 当发生错误时自动重启
    hostname: zoo1
    container_name: zoo1
    privileged: true
    ports: # 端口
      - 2181:2181
    volumes: # 挂载数据卷
      - ./zoo1/data:/data
      - ./zoo1/datalog:/datalog 
    environment:
      TZ: Asia/Shanghai
      ZOO_MY_ID: 1 # 节点ID
      ZOO_PORT: 2181 # zookeeper端口号
      ZOO_SERVERS: server.1=zoo1:2888:3888 server.2=zoo2:2888:3888 server.3=zoo3:2888:3888 # zookeeper节点列表

  zoo2:
    image: zookeeper:3.4
    restart: always
    hostname: zoo2
    container_name: zoo2
    privileged: true
    ports:
      - 2182:2181
    volumes:
      - ./zoo2/data:/data
      - ./zoo2/datalog:/datalog
    environment:
      TZ: Asia/Shanghai
      ZOO_MY_ID: 2
      ZOO_PORT: 2181
      ZOO_SERVERS: server.1=zoo1:2888:3888 server.2=zoo2:2888:3888 server.3=zoo3:2888:3888

  zoo3:
    image: zookeeper:3.4
    restart: always
    hostname: zoo3
    container_name: zoo3
    privileged: true
    ports:
      - 2183:2181
    volumes:
      - ./zoo3/data:/data
      - ./zoo3/datalog:/datalog
    environment:
      TZ: Asia/Shanghai
      ZOO_MY_ID: 3
      ZOO_PORT: 2181
      ZOO_SERVERS: server.1=zoo1:2888:3888 server.2=zoo2:2888:3888 server.3=zoo3:2888:3888

networks:
  default:
    external:
      name: zoo_kafka
EOF

docker-compose -f docker-compose-zk.yml up -d
```

4、#创建kafka集群
```bash
cat > docker-compose-kafka.yml <<-EOF
version: '2'
services:
  broker1:
    image: wurstmeister/kafka
    restart: always
    hostname: broker1
    container_name: broker1
    privileged: true
    ports:
      - "9091:9092"
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_LISTENERS: PLAINTEXT://broker1:9092
      #KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://broker1:9092  修复外部网络不能使用docker容器kafka集群问题
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://192.168.56.11:9091
      KAFKA_ADVERTISED_HOST_NAME: broker1
      KAFKA_ADVERTISED_PORT: 9092
      KAFKA_ZOOKEEPER_CONNECT: zoo1:2181,zoo2:2181,zoo3:2181
      JMX_PORT: 9988
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./broker1:/kafka/kafka\-logs\-broker1
    external_links:
    - zoo1
    - zoo2
    - zoo3

  broker2:
    image: wurstmeister/kafka
    restart: always
    hostname: broker2
    container_name: broker2
    privileged: true
    ports:
      - "9092:9092"
    environment:
      KAFKA_BROKER_ID: 2
      KAFKA_LISTENERS: PLAINTEXT://broker2:9092
      #KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://broker2:9092   
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://192.168.56.11:9092
      KAFKA_ADVERTISED_HOST_NAME: broker2
      KAFKA_ADVERTISED_PORT: 9092
      KAFKA_ZOOKEEPER_CONNECT: zoo1:2181,zoo2:2181,zoo3:2181
      JMX_PORT: 9988
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./broker2:/kafka/kafka\-logs\-broker2
    external_links:  # 连接本compose文件以外的container
    - zoo1
    - zoo2
    - zoo3

  broker3:
    image: wurstmeister/kafka
    restart: always
    hostname: broker3
    container_name: broker3
    privileged: true
    ports:
      - "9093:9092"
    environment:
      KAFKA_BROKER_ID: 3
      KAFKA_LISTENERS: PLAINTEXT://broker3:9092
      #KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://broker3:9092
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://192.168.56.11:9093
      KAFKA_ADVERTISED_HOST_NAME: broker3
      KAFKA_ADVERTISED_PORT: 9092
      KAFKA_ZOOKEEPER_CONNECT: zoo1:2181,zoo2:2181,zoo3:2181
      JMX_PORT: 9988
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./broker3:/kafka/kafka\-logs\-broker3
    external_links:  # 连接本compose文件以外的container
    - zoo1
    - zoo2
    - zoo3

  kafka-manager:
    image: hlebalbau/kafka-manager:latest
    restart: always
    container_name: kafka-manager
    hostname: kafka-manager
    ports:
      - "9000:9000"
    links:            # 连接本compose文件创建的container
      - broker1
      - broker2
      - broker3
    external_links:   # 连接本compose文件以外的container
      - zoo1
      - zoo2
      - zoo3
    environment:
      ZK_HOSTS: zoo1:2181,zoo2:2181,zoo3:2181
      KAFKA_BROKERS: broker1:9092,broker2:9092,broker3:9092
      APPLICATION_SECRET: "random-secret"
      KAFKA_MANAGER_AUTH_ENABLED: "true"
      KAFKA_MANAGER_USERNAME: "admin"
      KAFKA_MANAGER_PASSWORD: "password"
    command: -Dpidfile.path=/dev/null

networks:
  default:
    external:   # 使用已创建的网络
      name: zoo_kafka
EOF

docker-compose -f docker-compose-kafka.yml up -d
```

5、#验证
```bash
http://192.168.56.11:9000/

#Cluster Zookeeper Hosts中填入:
zoo1:2181/kafka1,zoo2:2181/kafka1,zoo3:2181/kafka1

https://www.cnblogs.com/yingww/p/9188701.html   docker下部署kafka集群(多个broker+多个zookeeper)
```

# 七、问题
```
1、修复问题
Yikes! Ask timed out on [ActorSelection[Anchor(akka://kafka-manager-system/), Path(/user/kafka-manager)]] after [5000 ms]

原因为连接不上zookeeper报错导致

```

参考资料：

http://zhongmingmao.me/2018/10/08/kafka-install-cluster-docker/   kafka-manager认证

https://yq.aliyun.com/articles/716134  Docker如何搭建Zookeeper、Kafka集群？

https://www.cnblogs.com/yingww/p/9188701.html  docker下部署kafka集群(多个broker+多个zookeeper)

https://www.jianshu.com/p/240d9166aaaf   Docker容器安装单机Kafka

https://johng.cn/install-kafka-with-docker/

https://www.cnblogs.com/wonglu/p/8687488.html   Kafka单机配置部署

https://www.jianshu.com/p/2425b9b34165  Kafka安装启动入门教程

https://www.cnblogs.com/hongdada/p/8117677.html  ZooKeeper 增加Observer部署模式提高性能

