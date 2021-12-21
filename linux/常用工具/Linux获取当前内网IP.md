# 一、获取方式一

```bash
root># hostname -I | awk -F " " '{printf $1}'
172.30.186.162
```

# 二、获取脚本

```bash
root># cat getip.sh
#!/bin/bash
IP=$(hostname -I | awk -F " " '{printf $1}')
echo $IP
root># sh getip.sh
172.30.186.162
```

# 三、获取方式三

```bash
root># hostIp=$(ip addr | grep inet | egrep -v '(127.0.0.1|inet6|docker)' | awk '{print $2}' | tr -d "addr:" | head -n 1 | cut -d / -f1)

root># echo $hostIp
172.30.186.162
```

参考资料：

https://blog.csdn.net/qq_26003101/article/details/113551948  CentOS脚本获取当前内网IP
