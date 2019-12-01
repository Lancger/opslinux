# 一、安装
```
chattr -i /etc/passwd* && chattr -i /etc/group* && chattr -i /etc/shadow* && chattr -i /etc/gshadow*
cd /usr/local/src
wget -N http://nginx.org/packages/rhel/7/x86_64/RPMS/nginx-1.16.0-1.el7.ngx.x86_64.rpm
rpm -Uvh nginx-1.16.0-1.el7.ngx.x86_64.rpm 

#卸载
rpm -e nginx-1.16.0-1.el7.ngx.x86_64

rpm -qa|grep nginx|xargs rpm -e
```

# 二、启动
```
systemctl restart nginx

systemctl enable nginx
```
# 三、日志切割
```
cat >/etc/logrotate.d/nginx<<\EOF
/var/log/nginx/*.log
{
  daily
  rotate 50
  missingok
  dateext
  compress
  notifempty
  sharedscripts
  postrotate
    [ -e /var/run/nginx.pid ] && kill -USR1 `cat /var/run/nginx.pid`
  endscript
}
EOF

#测试
logrotate -vf /etc/logrotate.d/nginx

ls /var/log/nginx/* -lh

#添加定时任务
59 23 * * * /usr/sbin/logrotate -vf /etc/logrotate.d/nginx
```
