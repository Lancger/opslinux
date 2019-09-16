今天在linux服务器上创建的用户，登录后发现此用户的CRT的终端提示符显示的是-bash-4.2# 而不是user@主机名 + 路径的显示方式，以往一直用的脚本也不能执行起来；
原因是在用useradd添加普通用户时，有时会丢失家目录下的环境变量文件，丢失文件如下：
1、.bash_profile
2、.bashrc
以上这些文件是每个用户都必备的文件。
此时可以使用以下命令从主默认文件/etc/skel/下重新拷贝一份配置信息到此用户家目录下

```
cp /etc/skel/.bashrc  /home/www/
cp /etc/skel/.bash_profile   /home/www/
```

参考文档：

https://blog.csdn.net/weixin_43279032/article/details/84531082
