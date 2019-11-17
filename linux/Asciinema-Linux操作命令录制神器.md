# 一、安装
```
# CentOS or RedHat

yum install epel-release -y
yum install asciinema -y

# pip 

pip3 install asciinema
```

# 二、自动录制审计日志

如果你有经历过严格的IT审计，或者有用到堡垒机，就会知道操作过程是需要记录并加入审计的，如果你有因为不知道是谁操作了什么导致了数据被删而背锅的经历，就会知道对操作过程的记录有多么的重要，接下来以一个简单的案例来介绍asciinema有什么样的实用价值。

非常简单，只需要在 devuser 用户的家目录下添加.bash_profile文件即可，内容如下：

```bash
$ cat ~/.bash_profile
export LC_ALL=en_US.UTF-8
/usr/bin/asciinema rec /tmp/$USER-$(date +%Y%m%d%H%M%S).log -q
```

添加export LC_ALL=en_US.UTF-8的原因是有可能系统会报错：
```bash
asciinema needs a UTF-8 native locale to run. Check the output of locale command.
```

rec命令进行录制时添加了-q 参数，这样在进入或者退出时都不会有任何关于 asciinema 的提示，使用简单方便。
这样 devuser 用户每次登陆就会自动开启一个录像，如果需要审计或检查操作，只需要回放录像就可以了。

你可能会说history命令一样可以记录用户操作，asciinema 有什么优势呢？asciinema 不仅可以记录用户的输入，还可以记录系统的输出，也就是说history只能记录执行的命令，而 asciinema 还可以记录执行的结果，怎么样，是不是很方便，赶紧试试吧。

参考资料：

https://www.yp14.cn/2019/11/16/Asciinema%EF%BC%9ALinux%E6%93%8D%E4%BD%9C%E5%91%BD%E4%BB%A4%E5%BD%95%E5%88%B6%E7%A5%9E%E5%99%A8/

https://mp.weixin.qq.com/s/oIKPy6zf1NXA4OfoQNkKGw 
