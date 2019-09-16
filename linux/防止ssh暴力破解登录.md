# 防暴力破解登录
```
cat > /usr/local/bin/Denyhosts.sh << \EOF
#!/bin/bash

#Denyhosts SHELL SCRIPT

cat /var/log/secure|awk '/Failed/{print $(NF-3)}'|sort|uniq -c|awk '{print $2"=" $1;}' >/tmp/Denyhosts.txt
DEFINE="15"
for i in `cat /tmp/Denyhosts.txt`
do
    IP=`echo $i|awk -F= '{print $1}'`
    NUM=`echo $i|awk -F= '{print $2}'`
    if [ $NUM -gt $DEFINE ]
    then
        ipExists=`grep $IP /etc/hosts.deny |grep -v grep |wc -l`
        if [ $ipExists -lt 1 ];then
            echo "sshd:$IP" >> /etc/hosts.deny
        fi
    fi
done
EOF
```
# 定时任务
```
*/1 * * * * /bin/bash /usr/local/bin/Denyhosts.sh
```
