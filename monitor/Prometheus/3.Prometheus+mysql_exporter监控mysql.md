# 一、mysqld_exporter安装及配置
```
cd /usr/local/src/

export VER="0.11.0"
wget https://github.com/prometheus/mysqld_exporter/releases/download/v${VER}/mysqld_exporter-${VER}.linux-amd64.tar.gz

tar -zxvf mysqld_exporter-${VER}.linux-amd64.tar.gz

mv mysqld_exporter-${VER}.linux-amd64 /data0/prometheus/mysqld_exporter

chown -R prometheus.prometheus /data0/prometheus

#赋权
mysqld_exporter需要连接到Mysql，所以需要Mysql的权限，我们先为它创建用户并赋予所需的权限：

#CREATE USER 'exporter'@'localhost' IDENTIFIED BY 'exporter';
#GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'localhost';

select User,Host from mysql.user;
delete from mysql.user where User="exporter" and Host='localhost';
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'localhost' IDENTIFIED BY "exporter";
flush privileges;
exit;
```

# 二、创建配置文件
```
cd /data0/prometheus/mysqld_exporter
cat << EOF > my.cnf
[client]
user=exporter
password=exporter
EOF
```

# 三、创建mysqld_exporter.service的 systemd unit 文件
```
cat <<EOF > /etc/systemd/system/mysqld_exporter.service
[Unit]
Description=mysqld_exporter
After=network.target

[Service]
Type=simple
User=prometheus
ExecStart=/data0/prometheus/mysqld_exporter/mysqld_exporter --config.my-cnf=/data0/prometheus/mysqld_exporter/my.cnf
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
```

# 四、启动myslqd_exporter
```
systemctl daemon-reload
systemctl restart mysqld_exporter
systemctl status mysqld_exporter
systemctl enable mysqld_exporter

验证
curl localhost:9104/metrics
```

# 五、Prometheus server配置拉取数据

利用 Prometheus 的 static_configs 来拉取 mysqld_exporter 的数据。

编辑prometheus.yml文件，添加内容
```
cat prometheus.yml
  - job_name: mysql_node3
    static_configs:
      - targets: ['192.168.56.13:9104']
```
重启prometheus，然后在Prometheus页面中的Targets中就能看到新加入的mysql

# 六、MySQL exporter Dashboard 模板

```
https://grafana.com/dashboards/7362
```
搜索mysql的Grafana Dashboard，导入进去

参考资料：

https://mp.weixin.qq.com/s?__biz=MzI1NjkzNDU4OQ==&mid=2247483975&idx=1&sn=9607317215ed8252968083cf09b9762d&scene=21%23wechat_redirect    构建狂拽炫酷屌的 MySQL 监控平台 

https://www.cnblogs.com/bigberg/p/10118215.html 

https://blog.csdn.net/hzs33/article/details/86553259  prometheus+grafana监控mysql、canal服务器
