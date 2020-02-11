```
yum install tcptraceroute -y

wget http://www.vdberg.org/~richard/tcpping

mv tcpping /usr/bin/

cd /usr/bin

chmod 755 tcpping

./tcpping www.aliyun.com 80
```

```
#服务端抓包
root># tcpdump -i any -n host 120.222.122.122 and port 1194
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on any, link-type LINUX_SLL (Linux cooked), capture size 262144 bytes
14:30:43.568678 IP 120.222.122.122.59762 > 172.32.0.12.openvpn: Flags [SEW], seq 748089256, win 65535, options [mss 1460,nop,wscale 6,nop,nop,TS val 276147467 ecr 0,sackOK,eol], length 0
14:30:43.568828 IP 172.32.0.12.openvpn > 120.222.122.122.59762: Flags [S.E], seq 2541597107, ack 748089257, win 28960, options [mss 1460,sackOK,TS val 3013183556 ecr 276147467,nop,wscale 9], length 0
14:30:44.572621 IP 120.222.122.122.59762 > 172.32.0.12.openvpn: Flags [S], seq 748089256, win 65535, options [mss 1460,nop,wscale 6,nop,nop,TS val 276148467 ecr 0,sackOK,eol], length 0
14:30:44.572672 IP 172.32.0.12.openvpn > 120.222.122.122.59762: Flags [S.E], seq 2541597107, ack 748089257, win 28960, options [mss 1460,sackOK,TS val 3013184560 ecr 276147467,nop,wscale 9], length 0
14:30:45.577707 IP 120.222.122.122.59762 > 172.32.0.12.openvpn: Flags [S], seq 748089256, win 65535, options [mss 1460,nop,wscale 6,nop,nop,TS val 276149467 ecr 0,sackOK,eol], length 0


#客户端测试
telnet 103.106.208.232 1194
发现不通
```

参考文档：

https://www.cnblogs.com/jonnyan/p/9662791.html
