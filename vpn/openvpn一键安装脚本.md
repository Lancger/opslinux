# 一、ubuntu配置openvpn
```
systemctl start openvpn@server

```
# 二、详细安装步骤
```bash
一、一键安装vpn
 
[root@localhost mnt]# wget https://git.io/vpn -O openvpn-install.sh;bash openvpn-install.sh 
Welcome to this OpenVPN "road warrior" installer!
 
I need to ask you a few questions before starting the setup.
You can leave the default options and just press enter if you are ok with them.
 
First, provide the IPv4 address of the network interface you want OpenVPN
listening to.
IP address: 10.50.215.95                      ----直接回车
 
This server is behind NAT. What is the public IPv4 address or hostname?
Public IP address / hostname: 10.50.215.95    ---填写本机外网ip
 
Which protocol do you want for OpenVPN connections?  --默认1可以直接回车，自行选择
   1) UDP (recommended)
   2) TCP
Protocol [1-2]: 2
 
What port do you want OpenVPN listening to?         --默认1可以直接回车，自行选择
Port: 1194
 
Which DNS do you want to use with the VPN?          --默认1可以直接回车，自行选择
   1) Current system resolvers
   2) 1.1.1.1
   3) Google
   4) OpenDNS
   5) Verisign
DNS [1-5]: 3
 
Finally, tell me your name for the client certificate.
Please, use one word only, no special characters.
Client name: client                     --创建vpn用户，默认client，可以直接回车，自行选择
………………………………………………………………………………………………………………………………
………………………………………………………………………………………………………………………………
Your client configuration is available at: /root/client.ovpn
If you want to add more clients, you simply need to run this script again!
```

参考资料：

https://blog.csdn.net/zzhlinux911218/article/details/85761991
