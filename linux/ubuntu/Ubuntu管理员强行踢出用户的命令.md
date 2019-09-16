
1、使用who查看一下都有谁在登录着服务器
```
who
```


2、现在我想踢出第一个用户
```
su # 切换到root
pkill -kill -t pts/0
```

参考资料：

https://www.jianshu.com/p/2edd3e0d4d43  301-Ubuntu 管理员强行踢出用户的命令
