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
```
# 二、ftp被动模式配置
```
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
listen=YES
listen_ipv6=NO
pam_service_name=vsftpd
userlist_enable=YES
tcp_wrappers=YES
listen_port=21
pasv_enable=YES
pasv_min_port=10000
pasv_max_port=20000
pasv_address=11.106.22.215
pasv_addr_resolve=YES
reverse_lookup_enable=NO
pasv_promiscuous=YES
EOF


systemctl start vsftpd.service
systemctl stop vsftpd.service
systemctl restart vsftpd.service
systemctl status  vsftpd.service
```

# 三、ftp主动模式配置
```
cat > /etc/vsftpd/vsftpd.conf << \EOF
local_root=/data0/ftpfile
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
anon_upload_enable=YES
anon_mkdir_write_enable=YES
anon_umask=022
dirmessage_enable=YES
xferlog_enable=YES
xferlog_std_format=YES
xferlog_file=/var/log/vsftpd.log
connect_from_port_20=YES
listen=YES
pam_service_name=vsftpd
userlist_enable=YES
tcp_wrappers=YES
pasv_promiscuous=YES
EOF

systemctl start vsftpd.service
systemctl stop vsftpd.service
systemctl restart vsftpd.service
systemctl status  vsftpd.service
```
# 四、ftp客户端
```
yum -y install ftp

ftp 103.106.20X.XX

#使用安全设置列出目录
ftp>ls
```

# 五、报错解决

1、425 Security: Bad IP connecting

```

解决方法：
https://blog.51cto.com/fullseo/1857562

主要是需要在/etc/vsftpd/vsftpd.conf文件中添加如下一行：

pasv_promiscuous=YES

此选项激活时，将关闭PASV模式的安全检查。该检查确保数据连接和控制连接是来自同一个IP地址。小心打开此选项。此选项唯一合理的用法是存在于由安全隧道方案构成的组织中。默认值为NO。 
合理的用法是：在一些安全隧道配置环境下，或者更好地支持FXP时(才启用它)。

service vsftpd restart
```

2、java ftp Host attempting data connection 172.33.0.7 is not same as server 问题

```
https://www.cnblogs.com/hisunhyx/p/5029476.html?utm_source=tuicool&utm_medium=referral
```

# 六、FTP主被动原理
```
https://www.cnblogs.com/ajianbeyourself/p/7655464.html
```

# 七、nginx代理ftp图片
```bash
cat >/etc/nginx/conf.d/ftp.conf<<\EOF
server {
    listen       80;
    server_name  localhost;

    #charset koi8-r;
    access_log  /var/log/nginx/host.access.log  main;

    location /pub/banner/ {
       alias /data0/ftpfile/pub/banner/;
       index  index.html index.htm;
       autoindex on;
    }

    location /bitcoin360/ {
       alias /data0/ftpfile/bitcoin360/;
       index  index.html index.htm;
       autoindex on;
    }
}
EOF

# 443 配置

server {
    listen       80;
    listen 443 ssl;
    server_name  ftp.coin.io;

    ssl_certificate      /etc/nginx/certs/coin.pem;
    ssl_certificate_key  /etc/nginx/certs/coin.key;
    ssl_session_timeout 5m;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
    ssl_protocols TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;

    #charset koi8-r;
    access_log  /var/log/nginx/ftp.coin.io.log  main;
    error_log /var/log/nginx/ftp.coin.io.error.log;

    location /pub/banner/ {
       alias /data0/ftpfile/pub/banner/;
       index  index.html index.htm;
       autoindex on;
    }

    location /coin/ {
       alias /data0/ftpfile/coin/;
       index  index.html index.htm;
       autoindex on;
    }
}
```
参考资料：

https://www.cnblogs.com/tdalcn/p/6940147.html  

https://www.jianshu.com/p/72a35e14c6bb

https://www.v5c87.com/2019/01/11/CentOS7%E6%90%AD%E5%BB%BAFTP%EF%BC%88%E8%A2%AB%E5%8A%A8%E6%A8%A1%E5%BC%8F%EF%BC%89/ CentOS7搭建FTP（被动模式）

https://blog.51cto.com/12476193/2308486  linux下VSFTPD的主动模式、被动模式和虚拟用户登录配置。
