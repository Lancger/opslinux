# 一、安装
```
#启动
consul agent -server -bootstrap-expect=2 -data-dir=/var/consul -node=node0 -bind=192.168.56.11 -datacenter=dc1 -ui -config-dir=/var/consul


consul agent -server -bootstrap-expect=2 -data-dir=/var/consul -node=node1 -bind=192.168.56.12 -datacenter=dc1 -config-dir=/var/consul


consul agent -data-dir=/var/consul -node=node3 -bind=192.168.56.13 -client=192.168.56.13 -datacenter=dc1 -config-dir=/var/consul


 nohup ./consul agent -ui -server -bootstrap-expect 2 -data-dir=data -node=consul01 -config-dir=conf -bind=10.33.16.224 -client=0.0.0.0 &

 nohup ./consul agent -server -bootstrap-expect 2 -data-dir=data -node=consul02 -config-dir=conf -bind=10.33.16.225 -client=0.0.0.0 &

nohup ./consul agent -server -bootstrap-expect 2 -data-dir=data -node=consul03 -config-dir=conf -bind=10.33.16.189 -client=0.0.0.0 &

#未加入集群疯狂报错
2019/04/30 19:22:37 [WARN] raft: no known peers, aborting election
2019/04/30 19:22:39 [ERR] agent: failed to sync remote state: No cluster leader
2019/04/30 19:23:03 [ERR] agent: Coordinate update error: No cluster leader
2019/04/30 19:23:16 [ERR] agent: failed to sync remote state: No cluster leader
2019/04/30 19:23:27 [ERR] agent: Coordinate update error: No cluster leader
2019/04/30 19:23:40 [ERR] agent: failed to sync remote state: No cluster leader
2019/04/30 19:23:59 [ERR] agent: Coordinate update error: No cluster leader
2019/04/30 19:24:14 [ERR] agent: failed to sync remote state: No cluster leader
2019/04/30 19:24:24 [ERR] agent: Coordinate update error: No cluster leader
2019/04/30 19:24:45 [ERR] agent: failed to sync remote state: No cluster leader
2019/04/30 19:24:58 [ERR] agent: Coordinate update error: No cluster leader

#加入集群
[root@linux-node1 ~]# consul join 192.168.56.12
Successfully joined cluster by contacting 1 nodes.

[root@linux-node1 ~]#  consul join 192.168.56.13
Successfully joined cluster by contacting 1 nodes.

```

二、# 访问
```
http://192.168.56.11:8500/ui/
```

参考链接：

https://www.cnblogs.com/xiaohanlin/p/8016803.html   服务发现 - consul 的介绍、部署和使用


https://www.lijiaocn.com/%E9%A1%B9%E7%9B%AE/2018/08/17/consul-usage.html  服务治理工具consul的功能介绍与使用入门


https://segmentfault.com/a/1190000016677665  consul集群搭建以及ACL配置
