# 一、秘钥分发脚本

```
cat > /tmp/ssh-dist.sh << \EOF
#!/bin/bash
yum -y install sshpass

# confirm the user of the operation 
echo "The current user is `whoami`"

# 1.generate the key pair
# 判断key是否已经存在，如果不存在就生成新的key
if [ -f ~/.ssh/id_rsa ];then
    echo "rsa ssh-key file already exists" /bin/true
else
    echo "rsa ssh-key file does not exists"
    ssh-keygen -t rsa -f ~/.ssh/id_rsa -P "" >/dev/null 2>&1
    if [ $? -eq 0 ];then
        echo "generate rsa ssh-key" /bin/true
    else
        echo "generate rsa ssh-key" /bin/false
        exit 1
    fi
fi

# 2.distribution public key
for host in $(cat ./ssh-ip | grep -v "#" | grep -v ";" | grep -v "^$")
do
    ip=$(echo ${host} | cut -f1 -d ":")
    password=$(echo ${host} | cut -f2 -d ":")
    user=root
    port_ip=$(echo ${user}@${ip})
    sshpass -p "${password}" ssh-copy-id -i ~/.ssh/id_rsa.pub -o StrictHostKeyChecking=no ${port_ip}
    if [ $? -eq 0 ];then
        echo "${ip} distribution public key" /bin/true
    else
        echo "${ip} distribution public key" /bin/false
        exit 1
    fi
done
EOF
```
```
chmod +x /tmp/ssh-dist.sh
```

# 二、配置需要下发的主机ip和密码
```
# 格式如下：
ip:密码

cat > /tmp/ssh-ip <<\EOF
192.168.56.11:123456
192.168.56.12:123456
EOF
```
# 三、使用方法
```
sh /tmp/ssh-dist.sh

```
参考资料：

https://cloud.tencent.com/developer/article/1403965  Linux 通过RSA公钥实现SSH免密码登录
