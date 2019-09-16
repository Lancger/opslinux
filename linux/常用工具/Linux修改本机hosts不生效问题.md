```
3). 如果重启服务器后，还是不起作用，应该是本机的dns缓存引起的。

查看nscd是否启用： ps -ef|grep nscd

直接关闭Linux nscd 缓存服务：
/etc/init.d/nscd stop


systemctl stop nscd
```
参考资料：

https://www.cnblogs.com/quwaner/p/7873370.html
