# 一、docker安装zabbix 4.0.1版本

容器化zabbix。

容器部署zabbix更简单

准备两台机器：
```bash
192.168.56.138 zabbix-server
192.168.56.131 zabbix-agent
```
软件版本：
```
docker: 18.06.1-ce
zabbix: 4.0.1
```

## 二、开始部署zabbix_server：

192.168.56.138上操作：

```
[root@server ~]# useradd mysql

[root@server ~]# mkdir -p /data/zabbix/mysql

[root@server ~]# chown -R mysql.mysql  /data/zabbix/mysql

[root@server ~]# docker run --name mysql-server -t \
      -e MYSQL_DATABASE="zabbix" \
      -e MYSQL_USER="zabbix" \
      -e MYSQL_PASSWORD="zabbix_pwd" \
      -e MYSQL_ROOT_PASSWORD="root_pwd" \
      -v /data/zabbix/mysql:/var/lib/mysql \
      -d mysql:5.7
      
[root@server ~]# docker run --name zabbix-server-mysql -t \
      -e DB_SERVER_HOST="mysql-server" \
      -e MYSQL_DATABASE="zabbix" \
      -e MYSQL_USER="zabbix" \
      -e MYSQL_PASSWORD="zabbix_pwd" \
      -e MYSQL_ROOT_PASSWORD="root_pwd" \
      --link mysql-server:mysql \
      -p 10051:10051 \
      -d zabbix/zabbix-server-mysql:latest
      
 [root@server ~]# docker run --name zabbix-web-nginx-mysql -t \
      -e DB_SERVER_HOST="mysql-server" \
      -e MYSQL_DATABASE="zabbix" \
      -e MYSQL_USER="zabbix" \
      -e MYSQL_PASSWORD="zabbix_pwd" \
      -e MYSQL_ROOT_PASSWORD="root_pwd" \
      --link mysql-server:mysql \
      --link zabbix-server-mysql:zabbix-server \
      -p 80:80 \
      -d zabbix/zabbix-web-nginx-mysql:latest
      
[root@server ~]# docker run --name zabbix-agent \
            -e ZBX_HOSTNAME="www.server.com" \
            -e ZBX_SERVER_HOST="192.168.56.138" \
            -e ZBX_METADATA="Linux" \
            -p 10050:10050 \
            --privileged \
            -d zabbix/zabbix-agent:latest
```
安装完成，浏览器上访问：http://192.168.56.138/zabbix      Admin/zabbix

## 三、开始部署zabbix_agent

192.168.56.131 上操作：

```
[root@agent ~]# docker run --name zabbix-agent \
            -e ZBX_HOSTNAME="www.web01.com" \
            -e ZBX_SERVER_HOST="192.168.56.138" \
            -e ZBX_METADATA="Linux" \
            -p 10050:10050 \
            --privileged \
            -d zabbix/zabbix-agent:latest
```

参考资料：

http://blog.51cto.com/passed/2321191
