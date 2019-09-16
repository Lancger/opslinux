# 一、介绍

本文档主要部署基于三个 server 和 一个 node 的 consul 集群，集群机器环境如下：

```
consul-server1  192.168.56.11
consul-server2  192.168.56.12
consul-server3  192.168.56.13
consul-client1  192.168.56.14
```

Consul 默认常用的端口如下：
```
dns       8600.
http      8500.
https     disabled
rpc       8400.
serf_lan  8301.
serf_wan  8302.
server    8300.

为了更友好的利用这些端口，建议容器的网络模式选择 --net=host 模式。
```

# 二、部署 consul-server1
```
docker run -d --name=consul-server1 \
     --net=host \
     --restart=always \
     -h consul-server1 \
     consul agent \
     -server \
     -bind=192.168.56.11 \
     -bootstrap-expect=2 \
     -node=consul-server1 \
     -data-dir=/tmp/data-dir \
     -client 0.0.0.0 \
     -ui
     
查看容器启动日志可以参考如下命令：

docker logs -f consul-server1

因为使用了-bootstrap-expect=2 参数，所以当 server 数量达到 3 个之前 consul 是不会引导集群的，当然也不会选出某一个 leader

至此，consul-server1 部署基本完成。
```

# 三、部署 consul-server2

和部署 consul-server1 类似，部署 consul-server2 时利用如下命令即可：

```
docker run -d --name=consul-server2 \
     --net=host \
     --restart=always \
     -h consul-server2 \
     consul agent \
     -server \
     -bind=192.168.56.12 \
     -join=192.168.56.11 \
     -bootstrap-expect=2 \
     -node=consul-server2 \
     -data-dir=/tmp/data-dir \
     -client 0.0.0.0 \
     -ui
     
查看容器启动日志可以参考如下命令：

docker logs -f consul-server2

至此，consul-server1 部署基本完成。

```

# 四、部署 consul-server3

和部署 consul-server1 类似，部署 consul-server3 时利用如下命令即可：

```
docker run -d --name=consul-server3 \
     --net=host \
     --restart=always \
     -h consul-server3 \
     consul agent \
     -server \
     -bind=192.168.56.13 \
     -join=192.168.56.11 \
     -bootstrap-expect=2 \
     -node=consul-server3 \
     -data-dir=/tmp/data-dir \
     -client 0.0.0.0 \
     -ui
     
查看容器启动日志可以参考如下命令：

docker logs -f consul-server3

至此，consul-server1 部署基本完成。

```

当三个 server 主机启动后， consul 就可以引导整个集群了，并且三个 server 之间通过 GRAF 机制选举出一个 leader 角色用来维护整个集群功能。集体选举过程可以通过日志查看到。

日志实例可以参考下面内容：


# 五、部署 consul-client1

其实，部署 client 和部署 server 类似，都是通过 consul agent 来部署，只是他们在 consul 层面扮演的角色不同而已。

部署 consul-client 用如下命令即可：

```
docker run -d --name=consul-client1 \
     --net=host \
     --restart=always \
     -h consul-client1 \
     consul agent \
     -bind=192.168.56.11 \
     -retry-join=192.168.56.11 \
     -node=consul-client1 \
     -client 0.0.0.0 \
     -ui

查看容器启动日志可以参考如下命令：

docker logs -f consul-client1

至此，consul-server1 部署基本完成。
```

# 六、查看集群状态

我们可以用如下命令查看集群状态和成员：

```
docker exec consul-server1 consul members
```

我们也可以通过 http 接口查看集群状态信息：
```
# 查看集群 leader
curl http://192.168.56.14:8500/v1/status/leader
"192.168.56.11:8300"

# 查看集群成员
curl http://192.168.56.14:8500/v1/status/peers
["192.168.56.11:8300","192.168.56.12:8300","192.168.56.13:8300"]

# 查看某个服务
curl http://192.168.56.14:8500/v1/catalog/service/redis

# 查看某个服务的健康状态
curl http://192.168.56.14:8500/v1/health/service/nginx?passing
```

当然，我们也可以通过 consul 自带的 ui 界面查看集群信息，默人 ui 访问地址：http://192.168.56.11:8500 ，具体页面参考如下：

至此，整个 consul 集群部署完成。如果需要其他方式部署 consul 集群可以查阅 consul 官方文档：https://www.consul.io/docs/install/index.html

参考文档：

https://aeric.io/post/consul-cluster-installation-with-containers/  容器化部署 Consul 集群
