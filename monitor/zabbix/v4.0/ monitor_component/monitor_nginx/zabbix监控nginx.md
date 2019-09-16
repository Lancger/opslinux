# 一、启用nginx status配置

nginx和php-fpm一样内建了一个状态页，对于想了解nginx的状态以及监控nginx非常有帮助。为了后续的zabbix监控，我们需要先了解nginx状态页是怎么回事。

1. 启用nginx status配置

在默认主机里面加上location或者你希望能访问到的主机里面。

新增一个 default.conf 文件
```
server {
    listen  *:80 default_server;
    server_name _;
    location /ngx_status 
    {
        stub_status on;
        access_log off;
        allow 127.0.0.1;
        deny all;
    }
}
```
2. 重启nginx
```
service nginx restart

systemctl start nginx
```

3. 打开status页面
```
curl http://127.0.0.1/ngx_status

Active connections: 11921 
server accepts handled requests
 11989 11989 11991 
Reading: 0 Writing: 7 Waiting: 42
```

4. nginx status详解
```
active connections – 活跃的连接数量
server accepts handled requests — 总共处理了11989个连接 , 成功创建11989次握手, 总共处理了11991个请求
reading — 读取客户端的连接数.
writing — 响应数据到客户端的数量
waiting — 开启 keep-alive 的情况下,这个值等于 active – (reading+writing), 意思就是 Nginx 已经处理完正在等候下一次请求指令的驻留连接.
```

# 二、zabbix客户端配置

1、编写客户端脚本ngx_status.sh

vim ngx_status.sh

```
#!/bin/bash
# DateTime: 2019-05-20
# AUTHOR：Bryan
# Description：zabbix监控nginx性能以及进程状态

HOST="127.0.0.1"
PORT="80"

# 检测nginx进程是否存在
function ping {
    /sbin/pidof nginx | wc -l 
}
# 检测nginx性能
function active {
    /usr/bin/curl "http://$HOST:$PORT/ngx_status/" 2>/dev/null| grep 'Active' | awk '{print $NF}'
}
function reading {
    /usr/bin/curl "http://$HOST:$PORT/ngx_status/" 2>/dev/null| grep 'Reading' | awk '{print $2}'
}
function writing {
    /usr/bin/curl "http://$HOST:$PORT/ngx_status/" 2>/dev/null| grep 'Writing' | awk '{print $4}'
}
function waiting {
    /usr/bin/curl "http://$HOST:$PORT/ngx_status/" 2>/dev/null| grep 'Waiting' | awk '{print $6}'
}
function accepts {
    /usr/bin/curl "http://$HOST:$PORT/ngx_status/" 2>/dev/null| awk NR==3 | awk '{print $1}'
}
function handled {
    /usr/bin/curl "http://$HOST:$PORT/ngx_status/" 2>/dev/null| awk NR==3 | awk '{print $2}'
}
function requests {
    /usr/bin/curl "http://$HOST:$PORT/ngx_status/" 2>/dev/null| awk NR==3 | awk '{print $3}'
}
# 执行function
$1
```

2、zabbix客户端配置

将自定义的UserParameter加入配置文件，然后重启agentd，如下：
```
cat /etc/zabbix/zabbix_agentd.conf | grep nginx
UserParameter=nginx.status[*],/etc/zabbix/scripts/ngx-status.sh $1
```

3、zabbix_get获取数据
```
zabbix_get -s 127.0.0.1 -k 'nginx.status[ping]'
```

# 三、zabbix web端配置


https://www.cnblogs.com/bluecarrife/p/9229693.html  zabbix监控Nginx模板
参考文档：

http://www.ttlsa.com/zabbix/zabbix-monitor-nginx-performance/ 
