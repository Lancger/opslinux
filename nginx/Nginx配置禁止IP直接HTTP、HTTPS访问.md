```
#http
server 
{
  listen 80 default_server;
  server_name _;
  return 403;
}

#https
server 
{
  listen 443 ssl default_server;
  server_name _;
  ssl_certificate      /usr/local/nginx/conf/cert/2018.pem;
  ssl_certificate_key  /usr/local/nginx/conf/cert/2018.key;
  return 403;
}
```

参考资料：

https://www.centos.bz/2017/12/nginx%E9%85%8D%E7%BD%AE%E7%A6%81%E6%AD%A2ip%E7%9B%B4%E6%8E%A5http-https%E8%AE%BF%E9%97%AE/
