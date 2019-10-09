```
在CentOS 6上，DHCP客户端配置位于特定于接口的文件中。对于公共接口eth0，配置文件为/etc/dhcp/dhclient-eth0.conf。由于这仅对有效eth0，因此我们可以简单地添加以下行

supersede interface-mtu 1500;
到这个文件。

要激活更改的配置，您只需要重新启动界面即可：

[root@centos ~]# ifdown eth0; ifup eth0
请记住，如果您通过SSH登录，这可能会断开您的连接。
```

```
 [root@centos ~]# nmcli connection modify "System eth0" ethernet.mtu 1500
```
参考资料：

https://www.cnblogs.com/idontknowthisperson/p/11098823.html  MacBook ssh卡在debug1: SSH2_MSG_KEXINIT sent的解决办法


https://devops.ionos.com/tutorials/override-dhcp-settings-on-centos/   centos 6 7 DHCP修改MTU
