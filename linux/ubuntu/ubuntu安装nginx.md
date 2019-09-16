```
sudo apt-get remove nginx* && sudo apt-get install nginx-full*


vim /etc/nginx/sites-enabled/default
注释
listen [::]:80 default_server;


systemctl restart nginx

Reinstall nginx:

apt purge nginx
apt autoremove
apt install nginx
```
参考文档：

https://askubuntu.com/questions/764222/nginx-installation-error-in-ubuntu-16-04

https://segmentfault.com/a/1190000014027697


https://my.oschina.net/u/1036767/blog/784628 nginx: [emerg] socket() [::]:80 failed (97: Address family not supported by protocol)
