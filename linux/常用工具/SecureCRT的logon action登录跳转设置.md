在公司干活，大家都要经常通过跳板机跳到外网的服务器上，如果每次都要先登录跳板机，然后再ssh到外网的服务器，的确有点坑，特别是在服务器数量较多的情况下，之前就用过securecrt的logon actions设置，但这次无论怎么样都无法直接跳到外网的机器，原来对logon actions的跳转原理还是不清晰。首先讲如下进行跳转把：

![securecrt跳转](https://github.com/Lancger/opslinux/blob/master/images/securecrt-01.png)

点击logon actions菜单，选中Automate logon复选框，然后编辑登录后需要send的命令和密码，Expect这个field的意思是：在登录后，遇到该expect的描述，就执行Send中的命令。而我的跳板机登录后显示的信息如下：

![securecrt跳转](https://github.com/Lancger/opslinux/blob/master/images/securecrt-02.png)

shell提示为:~>，所以我之前一直在logon actions中使用默认的Expect：ogin：，所以一直跳转不了：

![securecrt跳转](https://github.com/Lancger/opslinux/blob/master/images/securecrt-03.png)

参考资料：

https://blog.csdn.net/sole_cc/article/details/51470311 
