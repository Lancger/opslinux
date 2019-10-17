# 一、下载zookeeper安装包

```
cd /usr/local/src/
wget https://archive.apache.org/dist/zookeeper/zookeeper-3.4.10/zookeeper-3.4.10.tar.gz
```

# 二、安装zookeeper
```
#首先创建Zookeeper项目目录
mkdir -p /data0/zookeeper
cd /data0/zookeeper
mkdir zkdata
mkdir zkdatalog

cd /usr/local/src/
tar zxvf zookeeper-3.4.10.tar.gz
mv zookeeper-3.4.10/ /usr/local/zookeeper
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

# 三、服务启动
```
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

# 四、检查状态
```
/usr/local/zookeeper/bin/zkServer.sh status /usr/local/zookeeper/conf/zoo.cfg

ZooKeeper JMX enabled by default
Using config: /usr/local/zookeeper/conf/zoo.cfg
Mode: leader
```

# 五、连接测试

```
/usr/local/zookeeper/bin/zkCli.sh -server 172.18.8.24:2181

```
参考资料：

https://segmentfault.com/a/1190000009983727
参考资料：

https://www.cnblogs.com/wonglu/p/8687488.html  Kafka单机配置部署
