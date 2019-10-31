# 一、代理配置
```bash
cat >/etc/nginx/conf.d/download.conf<<\EOF
server {
    listen       80 default_server;
    listen       [::]:80 default_server;

    server_name  download.devops.com;

    location / {
        root    /usr/share/nginx/html/download;
        autoindex on;              #开启索引功能
        autoindex_exact_size off;  #关闭计算文件确切大小（单位bytes），只显示大概大小（单位kb、mb、gb）
        autoindex_localtime on;    #显示本机时间而非 GMT 时间
    }

    error_page 404 /404.html;
        location = /40x.html {
    }

    error_page 500 502 503 504 /50x.html;
        location = /50x.html {
    }
}
EOF

systemctl restart nginx
```

# 下载测试
```
wget http://download.devops.com/a.tar.gz
```
