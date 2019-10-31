# 一、环境介绍

```
系统：centos7
服务器：
172.18.8.24
172.18.8.25
172.18.8.26
```

# 二、下载zookeeper安装包

```
cd /usr/local/src/
wget https://archive.apache.org/dist/zookeeper/zookeeper-3.4.10/zookeeper-3.4.10.tar.gz
```

# 三、安装zookeeper
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
server.1=172.18.8.24:3181:4181
server.2=172.18.8.25:3181:4181
server.3=172.18.8.26:3181:4181
EOF

#创建myid文件，节点对应id
在24机器上创建myid，并设置为1与配置文件zoo.cfg里面server.1对应。
echo "1" > /data0/zookeeper/zkdata/myid

在25机器上创建myid，并设置为2与配置文件zoo.cfg里面server.2对应。
echo "2" > /data0/zookeeper/zkdata/myid

在26机器上创建myid，并设置为3与配置文件zoo.cfg里面server.3对应。
echo "3" > /data0/zookeeper/zkdata/myid
```

# 四、服务启动
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

# 五、检查状态
```
/usr/local/zookeeper/bin/zkServer.sh status /usr/local/zookeeper/conf/zoo.cfg

ZooKeeper JMX enabled by default
Using config: /usr/local/zookeeper/conf/zoo.cfg
Mode: leader
```

# 六、连接测试

```bash
/usr/local/zookeeper/bin/zkCli.sh -server 172.18.8.24:2181

#查看zookeeper的配置
echo conf | nc 127.0.0.1 2181

#查看哪个节点被选择作为follower或者leader
echo stat|nc 127.0.0.1 2181

```
参考资料：

https://segmentfault.com/a/1190000009983727

https://blog.csdn.net/zero__007/article/details/81090194  nc命令获取zookeeper信息 
