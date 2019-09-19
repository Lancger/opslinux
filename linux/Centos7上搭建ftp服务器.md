# 一、ftp服务端
```
yum -y install vsftpd

mkdir /data0/ftpfile                              # 新建目录
useradd ftpuser -d /tmp/ftpfile -s /sbin/nologin  # 新建不可登录用户
chown -R ftpuser.ftpuser /data0/ftpfile           # 将归属改成新用户
echo "vLpxdMIA2EZPsDIv" |passwd --stdin ftpuser   # 给新用户设密码


cat > /etc/vsftpd/chroot_list << \EOF
ftpuser
EOF


cat > /etc/vsftpd/vsftpd.conf << \EOF
anonymous_enable=YES
local_root=/data0/ftpfile 
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
xferlog_enable=YES
connect_from_port_20=YES
xferlog_std_format=YES
xferlog_file=/var/log/vsftpd.log
listen=NO
listen_ipv6=YES
pam_service_name=vsftpd
userlist_enable=YES
tcp_wrappers=YES
listen_port=21
pasv_enable=YES
pasv_min_port=10000
pasv_max_port=20000
pasv_address=103.106.20x.xx
pasv_addr_resolve=YES
reverse_lookup_enable=NO
pasv_promiscuous=YES
EOF


systemctl start vsftpd.service
systemctl stop vsftpd.service
systemctl restart vsftpd.service
systemctl status  vsftpd.service

```

# 二、ftp客户端
```
yum -y install ftp

ftp 103.106.20X.XX
```

参考资料：

https://www.cnblogs.com/tdalcn/p/6940147.html  

https://www.jianshu.com/p/72a35e14c6bb

https://www.v5c87.com/2019/01/11/CentOS7%E6%90%AD%E5%BB%BAFTP%EF%BC%88%E8%A2%AB%E5%8A%A8%E6%A8%A1%E5%BC%8F%EF%BC%89/ CentOS7搭建FTP（被动模式）

