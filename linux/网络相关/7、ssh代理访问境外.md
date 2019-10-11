```
ssh -i id_salt_rsa -p 33389 -qTCnfND 7070 root@192.169.*.* (公网服务器)


#测试
curl --proxy socks5://127.0.0.1:7070 google.com
curl --socks5 127.0.0.1:7070 google.com

```
参考资料：

http://blog.wdlyb.com/tools-for-vps.html  
