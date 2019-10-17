# 一、zookeeper部署
```
docker pull zookeeper
docker run -d --name=my_zookeeper --restart=always -p 2181:2181 zookeeper:latest
docker logs -f my_zookeeper

#使用 ZK 命令行客户端连接 ZK
docker run -it --rm --link my_zookeeper:zookeeper zookeeper zkCli.sh -server zookeeper
```



参考资料：

https://www.cnblogs.com/wonglu/p/8687488.html   Kafka单机配置部署

https://www.jianshu.com/p/2425b9b34165  Kafka安装启动入门教程
