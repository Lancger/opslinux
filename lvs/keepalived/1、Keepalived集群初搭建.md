```
第一次搭建Keepalived集群，实现IP漂移。
笔者所搭建Keepalived集群额外满足下面两个需求点：

监听HAProxy进程，一旦HAProxy进程不存在，可能触发IP漂移
互为主备，充分利用服务器资源

一、安装
Debian下安装命令如下：

sudo apt-get install keepalived
二、配置
默认配置文件路径为：“/etc/keepalived/keepalived.conf”。

2.1、主节点配置
由于互为主备，故同时包含备份节点配置。
具体配置如下：

global_defs {
  notification_email {
    # 通知信息邮件接收者邮箱
    xxx@domain.email 
  }
  # 通知信息邮件发送者邮箱
  notification_email_from keepalived@domain.email
  # 表示本地开启了一个SMTP Server进程，端口为默认端口25，通过该SMTP Server发送通知信息邮件
  smtp_server 127.0.0.1
  smtp_connect_timeout 4
}

vrrp_script chk_haproxy {
  # 存在haproxy进程返回0，否则返回非0
  script "killall -0 haproxy"
  # 每隔2秒运行监听脚本
  interval 2
  # 上述脚本执行连续3次返回0，则将“VRRP实例”的状态置为“正常态”，结合其他条件，可能触发IP漂移
  rise 3
  # 上述脚本执行连续3次返回非0，则将“VRRP实例”的状态置为“错误态”，结合其他条件，可能触发IP漂移
  fall 3
}

# 配置一个VRRP实例
vrrp_instance VI_101 {
  # 配置作为该VRRP实例的主节点
  state MASTER
  # 同一个VRRP实例下的节点（主节点和备份节点）具有相同值
  # 而且同一网段中virtual_router_id的值不能重复
  virtual_router_id 101
  # 在该VRRP实例中，本节点的优先级
  priority 100

  interface bond0
  track_interface {
    bond0
  }
  advert_int 1
  smtp_alert
  authentication {
    auth_type PASS
    auth_pass keep@lived
  }

  virtual_ipaddress {
    # 该VRRP实例的绑定到IP
    10.200.164.101/22
  }

  track_script {
    chk_haproxy
  }
}

# 配置另外一个VRRP实例
vrrp_instance VI_102 {
  # 配置作为该VRRP实例的备份节点
  state BACKUP
  # 同一个VRRP实例下的节点（主节点和备份节点）具有相同值
  # 而且同一网段中virtual_router_id的值不能重复
  virtual_router_id 102
  # 在该VRRP实例中，本节点的优先级
  priority 50

  interface bond0
  track_interface {
    bond0
  }
  advert_int 1
  smtp_alert
  authentication {
    auth_type PASS
    auth_pass keep@lived
  }

  virtual_ipaddress {
    # 该VRRP实例的绑定到IP
    10.200.164.102/22
  }

  track_script {
    chk_haproxy
  }
}
2.2、备份节点配置
由于互为主备，故同时包含主节点配置。
具体配置如下：

global_defs {
  notification_email {
    # 通知信息邮件接收者邮箱
    xxx@domain.email 
  }
  # 通知信息邮件发送者邮箱
  notification_email_from keepalived@domain.email
  # 表示本地开启了一个SMTP Server进程，端口为默认端口25，通过该SMTP Server发送通知信息邮件
  smtp_server 127.0.0.1
  smtp_connect_timeout 4
}

vrrp_script chk_haproxy {
  # 存在haproxy进程返回0，否则返回非0
  script "killall -0 haproxy"
  # 每隔2秒运行监听脚本
  interval 2
  # 上述脚本执行连续3次返回0，则将“VRRP实例”的状态置为“正常态”，结合其他条件，可能触发IP漂移
  rise 3
  # 上述脚本执行连续3次返回非0，则将“VRRP实例”的状态置为“错误态”，结合其他条件，可能触发IP漂移
  fall 3
}

# 配置一个VRRP实例
vrrp_instance VI_101 {
  # 配置作为该VRRP实例的备份节点
  state BACKUP 
  # 同一个VRRP实例下的节点（主节点和备份节点）具有相同值
  # 而且同一网段中virtual_router_id的值不能重复
  virtual_router_id 101
  # 在该VRRP实例中，本节点的优先级
  priority 50

  interface bond0
  track_interface {
    bond0
  }
  advert_int 1
  smtp_alert
  authentication {
    auth_type PASS
    auth_pass keep@lived
  }

  virtual_ipaddress {
    # 该VRRP实例的绑定到IP
    10.200.164.101/22
  }

  track_script {
    chk_haproxy
  }
}

# 配置另外一个VRRP实例
vrrp_instance VI_102 {
  # 配置作为该VRRP实例的主节点
  state MASTER 
  # 同一个VRRP实例下的节点（主节点和备份节点）具有相同值
  # 而且同一网段中virtual_router_id的值不能重复
  virtual_router_id 102
  # 在该VRRP实例中，本节点的优先级
  priority 100

  interface bond0
  track_interface {
    bond0
  }
  advert_int 1
  smtp_alert
  authentication {
    auth_type PASS
    auth_pass keep@lived
  }

  virtual_ipaddress {
    # 该VRRP实例的绑定到IP
    10.200.164.102/22
  }

  track_script {
    chk_haproxy
  }
}
三、启动，停止与重启
启动：sudo /etc/init.d/keepalived start
停止：sudo /etc/init.d/keepalived stop
重启：sudo /etc/init.d/keepalived restart

四、其他
4.1、同一网段中的virtual_router_id的值不能重复
特别需要注意的是，同一网段中的virtual_router_id(vrid)的值不能重复，否则会干扰其他Keepalived集群的正常运行。
可通过如下命令查看欲使用vrid值是否已经被使用：

sudo tcpdump -ani any vrrp | grep vrid
4.2、“VRRP实例的绑定到IP”对于所使用的网卡需要合法
比如使用网卡“bond0”，该网卡的掩码为“255.255.255.0”，那么所使用的“VRRP实例的绑定到IP”的掩码也必须为“255.255.255.0”，即具有“xxx.xxx.xxx.xxx/24”的形式。
```
参考资料：

https://dslztx.github.io/blog/2019/01/17/Keepalived%E9%9B%86%E7%BE%A4%E5%88%9D%E6%90%AD%E5%BB%BA/  Keepalived集群初搭建
