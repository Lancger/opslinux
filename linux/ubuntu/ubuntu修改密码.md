这刚一换个发行版，就发现之前学的命令不对版了。新装的系统没有初始root密码，需要用安装过程中创建的用户执行sudo passwd来修改。因为之前做练习用惯了下面这种方式

```
echo password | passwd --stdin user
```

但是发现这条命令在ubuntu里面不支持 --stdin 参数了。百度了一下，可以用以下的方式替代该命令

```
echo user:pass | chpasswd
```

参考资料：

https://blog.51cto.com/foolishfish/1537650   ubuntu下passwd不能使用--stdin参数的替代方法
