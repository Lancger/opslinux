```
<2019-09-02 19:16:52> /etc/nginx/conf.d
root># cat conf.d/ftp.conf 
server {
    listen       80;
    server_name  localhost;

    #charset koi8-r;
    access_log  /var/log/nginx/host.access.log  main;

    location /pub/banner/ {
       alias /data/ftpfile/pub/banner/;
       index  index.html index.htm;
       autoindex on; 
    }

    location /btc/banner/ {
       alias /data/ftpfile/btc/banner/;
       index  index.html index.htm;
       autoindex on;
    }
}
```

```
访问
http://13.106.218.242/pub/banner/1567416168807.png

http://13.106.218.242/btc/banner/1567416168807.png

```
