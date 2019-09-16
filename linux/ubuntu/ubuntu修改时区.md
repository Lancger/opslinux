```

1) 更改系统时区

ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime


2) 使用Systemd更改Linux系统时区

如果你使用的Linux系统使用Systemd，还可以使用timedatectl命令来更改Linux系统范围的时区。在Systemd下有一个名为systemd-timedated的系统服务负责调整系统时钟和时区，我们可以使用timedatectl命令对此系统服务进行配置：

sudo timedatectl set-timezone 'Asia/Shanghai'
```
参考资料：

https://ivanzz1001.github.io/records/post/linuxops/2018/02/06/linux-timezone   Ubuntu16.04操作系统环境下修改时区 
