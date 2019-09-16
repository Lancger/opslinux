# 一、TCP连接的三次握手--一次故障记录

    关于TCP的三次握手

    大家都知道tcp和udp协议，tcp可靠的网络传输协议，udp效率高但是不会进行传输确认，只有投递。

    那么三次握手就是为了保证tcp的可靠传输，下边是用wireshark抓取一次失败的http请求的结果：

  ![tcpdump-tcp](https://github.com/Lancger/opslinux/blob/master/images/tcpdump-tcp.jpg)

    首先TCP的三次握手是建立连接

    NO1，113.31的主机给112.65的主机发送了一个包含syn的包并且设置seq等于0，来请求建立连接

    NO2，112.65的主机给113.31的主机回复了一个syn+ack的包，并且seq也等于0，回复客户端，我同意建立请求

    NO3，113.31的主机给112.65的主机回复了一个ack的确认包，并且设置seq=1， 告诉服务器，连接以成功建立


    至于NO4的包，就是本次连接最关键的失败之处了

    NO4，113.31因为某种原因给服务端发送了一个rst（reset）报文，也就是重置连接的报文。

    NO5，仅接着113.31再次给服务器发送了一个HTTP的head请求，此时服务器便回复了客户端的rst报文

    NO6，服务器给客户端也回复rst，就同意服务器同意了reset本次连接，导致连接断开！！！


curl错误结果如下：

```
[root@Cwg ~]# curl -I http://www.testaaa.com/
curl: (56) Failure when receiving data from the peer

```

这个错误差了好长时间，就是不知道为什么，很明显NO4的报文和NO5的报文是冲突的，既然客户端首先提出重置连接，那么为什么后边还要搬起石头砸自己的脚发送一个http的head请求！！！

初步怀疑网络上可能有什么过滤设备导致的，但是客户的服务器也不得而知了，只能这么不了了之。

```
晚上回家后边走边想，如果客户端给服务器发送rst的包了之后为什么还要发送请求，这个问题有些想不通，然后再请求的时候客户端也抓包看看。。。
结果如下：

    [root@Cwg ~]# tcpdump -vvXe host 112.65.X.X
    tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size 65535 bytes
    09:24:36.947082 00:e0:4c:1c:1d:2a (oui Unknown) > 38:22:d6:a1:78:66 (oui Unknown), ethertype IPv4 (0x0800), length 74: (tos 0x0, ttl 64, id 3092, offset 0, flags [DF], proto TCP (6), length 60)
        188.188.3.240.a3-sdunode > www.testaaa.com.http: Flags [S], cksum 0xa4f2 (correct), seq 2466954207, win 14600, options [mss 1460,sackOK,TS val 949598155 ecr 0,nop,wscale 7], length 0
            0x0000:  4500 003c 0c14 4000 4006 1a26 bcbc 03f0  E..<..@.@..&....
            0x0010:  7041 e394 15e4 0050 930a bbdf 0000 0000  pA.....P........
            0x0020:  a002 3908 a4f2 0000 0204 05b4 0402 080a  ..9.............          //第一个包发送给服务器syn， flags 【s】就是sync，这个字段位标识了tcp的控制项下边再不多说
            0x0030:  3899 b7cb 0000 0000 0103 0307            8...........
    09:24:36.991519 38:22:d6:a1:78:66 (oui Unknown) > 00:e0:4c:1c:1d:2a (oui Unknown), ethertype IPv4 (0x0800), length 66: (tos 0x0, ttl 52, id 1216, offset 0, flags [none], proto TCP (6), length 52)
        www.testaaa.com.http > 188.188.3.240.a3-sdunode: Flags [S.], cksum 0x429c (correct), seq 1671696166, ack 2466954208, win 16384, options [mss 1460,nop,wscale 0,nop,nop,sackOK], length 0
            0x0000:  4500 0034 04c0 0000 3406 6d82 7041 e394  E..4....4.m.pA..
            0x0010:  bcbc 03f0 0050 15e4 63a4 0f26 930a bbe0  .....P..c..&....      //第二个包服务器发送给客户端syn+ack，这里的ack是ack 2466954208
            0x0020:  8012 4000 429c 0000 0204 05b4 0103 0300  ..@.B...........
            0x0030:  0101 0402                                ....
    09:24:36.991570 00:e0:4c:1c:1d:2a (oui Unknown) > 38:22:d6:a1:78:66 (oui Unknown), ethertype IPv4 (0x0800), length 54: (tos 0x0, ttl 64, id 3093, offset 0, flags [DF], proto TCP (6), length 40)
        188.188.3.240.a3-sdunode > www.testaaa.com.http: Flags [.], cksum 0xc2f4 (correct), seq 1, ack 1, win 115, length 0
            0x0000:  4500 0028 0c15 4000 4006 1a39 bcbc 03f0  E..(..@.@..9....
            0x0010:  7041 e394 15e4 0050 930a bbe0 63a4 0f27  pA.....P....c..'        //客户端回复服务器ack，三次握手完成
            0x0020:  5010 0073 c2f4 0000                      P..s....
    09:24:36.991639 00:e0:4c:1c:1d:2a (oui Unknown) > 38:22:d6:a1:78:66 (oui Unknown), ethertype IPv4 (0x0800), length 225: (tos 0x0, ttl 64, id 3094, offset 0, flags [DF], proto TCP (6), length 211)
        188.188.3.240.a3-sdunode > www.testaaa.com.http: Flags [P.], cksum 0x6dfa (correct), seq 1:172, ack 1, win 115, length 171
            0x0000:  4500 00d3 0c16 4000 4006 198d bcbc 03f0  E.....@.@.......
            0x0010:  7041 e394 15e4 0050 930a bbe0 63a4 0f27  pA.....P....c..'
            0x0020:  5018 0073 6dfa 0000 4845 4144 202f 2048  P..sm...HEAD./.H      //控制端p表示是PDU分片
            0x0030:  5454 502f 312e 310d 0a55 7365 722d 4167  TTP/1.1..User-Ag
            0x0040:  656e 743a 2063 7572 6c2f 372e 3139 2e37  ent:.curl/7.19.7
            0x0050:  2028 7838 365f 3634 2d72 6564 6861 742d  .(x86_64-redhat-
            0x0060:  6c69 6e75 782d 676e 7529 206c 6962 6375  linux-gnu).libcu
            0x0070:  726c 2f37 2e31 392e 3720 4e53 532f 332e  rl/7.19.7.NSS/3.
            0x0080:  3134 2e30 2e30 207a 6c69 622f 312e 322e  14.0.0.zlib/1.2.
            0x0090:  3320 6c69 6269 646e 2f31 2e31 3820 6c69  3.libidn/1.18.li
            0x00a0:  6273 7368 322f 312e 342e 320d 0a48 6f73  bssh2/1.4.2..Hos
            0x00b0:  743a 2077 7777 2e74 6573 7461 6161 2e63  t:.www.testaaa.c
            0x00c0:  6f6d 0d0a 4163 6365 7074 3a20 2a2f 2a0d  om..Accept:.*/*.
            0x00d0:  0a0d 0a                                  ...
    09:24:37.236117 00:e0:4c:1c:1d:2a (oui Unknown) > 38:22:d6:a1:78:66 (oui Unknown), ethertype IPv4 (0x0800), length 225: (tos 0x0, ttl 64, id 3095, offset 0, flags [DF], proto TCP (6), length 211)
        188.188.3.240.a3-sdunode > www.testaaa.com.http: Flags [P.], cksum 0x6dfa (correct), seq 1:172, ack 1, win 115, length 171
            0x0000:  4500 00d3 0c17 4000 4006 198c bcbc 03f0  E.....@.@.......
            0x0010:  7041 e394 15e4 0050 930a bbe0 63a4 0f27  pA.....P....c..'
            0x0020:  5018 0073 6dfa 0000 4845 4144 202f 2048  P..sm...HEAD./.H   //PDU分片
            0x0030:  5454 502f 312e 310d 0a55 7365 722d 4167  TTP/1.1..User-Ag
            0x0040:  656e 743a 2063 7572 6c2f 372e 3139 2e37  ent:.curl/7.19.7
            0x0050:  2028 7838 365f 3634 2d72 6564 6861 742d  .(x86_64-redhat-
            0x0060:  6c69 6e75 782d 676e 7529 206c 6962 6375  linux-gnu).libcu
            0x0070:  726c 2f37 2e31 392e 3720 4e53 532f 332e  rl/7.19.7.NSS/3.
            0x0080:  3134 2e30 2e30 207a 6c69 622f 312e 322e  14.0.0.zlib/1.2.
            0x0090:  3320 6c69 6269 646e 2f31 2e31 3820 6c69  3.libidn/1.18.li
            0x00a0:  6273 7368 322f 312e 342e 320d 0a48 6f73  bssh2/1.4.2..Hos
            0x00b0:  743a 2077 7777 2e74 6573 7461 6161 2e63  t:.www.testaaa.c
            0x00c0:  6f6d 0d0a 4163 6365 7074 3a20 2a2f 2a0d  om..Accept:.*/*.
            0x00d0:  0a0d 0a                                  ...
    09:24:37.279333 38:22:d6:a1:78:66 (oui Unknown) > 00:e0:4c:1c:1d:2a (oui Unknown), ethertype IPv4 (0x0800), length 60: (tos 0x0, ttl 52, id 1223, offset 0, flags [none], proto TCP (6), length 40)
        www.testaaa.com.http > 188.188.3.240.a3-sdunode: Flags [R], cksum 0x9f93 (correct), seq 1671696167, win 0, length 0
            0x0000:  4500 0028 04c7 0000 3406 6d87 7041 e394  E..(....4.m.pA..        //控制位R 表示reset连接    此处是服务器直接发送给客户端的，从开始到连接reset客户端只收到一个服务器发来的reset
            0x0010:  bcbc 03f0 0050 15e4 63a4 0f27 63a4 0f27  .....P..c..'c..'
            0x0020:  5004 0000 9f93 0000 0000 0000 0000       P.............
```

 从开始到结束客户端只收到一个reset包，说明服务器受到的第4个rst包并非客户端所发，导致服务器响应了reset而过早结束连接！！！
客户的环境是win2003_32+IIS6,站点内容是纯静态页面

服务器系统层面以上的防护措施为了便于排错都关闭了，客户决定把站挪走，此次事件便成了一件悬案！！！

########################


参考文档：

https://blog.csdn.net/cwg_1992/article/details/17426917   TCP连接的三次握手--一次故障记录
