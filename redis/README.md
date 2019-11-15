直接yum 安装的redis 不是最新版本

```
#刷新配置
systemctl daemon-reload

systemctl start redis
systemctl restart redis
systemctl stop redis

#开机自启动
systemctl enable redis
systemctl disable redis

#查看状态
systemctl status redis
```


参看资料：

https://www.cnblogs.com/autohome7390/p/6433956.html

https://blog.csdn.net/Fe_cow/article/details/89485883   Redis 基础入门

https://www.cnblogs.com/Dy1an/category/1492872.html   Redis专题博客
