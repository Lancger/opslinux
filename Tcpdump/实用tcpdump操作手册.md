```
实用tcpdump命令

  //查看本机与mysql的操作命令 注意 -i any表示监听所有网络接口，我们也根据自身情况选择网络接口
  #tcpdump -i any -w - dst port 3306 |strings  

  //查看本机58895上与mysql的命令   注意 -i any 表示监听所有网络接口，我们需要根据自身情况选择网络接口
  #tcpdump -i any -w - dst port 3306 and src port 58895 |strings  
  
  同理，也可以使用上面的命令，查看kafka,etcd,redis,mc等的命令情况,只要是明文协议都可以
  

tcpdump命令格式

  #tcpdump option filter
    option 举例 -n, -i any 等
    filter 是过滤包的条件，举例: tcp, portrange 1-1000, src port 58895, host www.itshouce.com.cn,
      filter可以进行组合 比如:
        dst port 3306 and src port 58895 
        portrange 1-1000 or src port 58895
        not dst port 3306
    
                  option                  filter
  举例: tcpdump   -i any -n    portrange 1-3306 or portrange 10000-58895
  
tcpdump option


  //在en2这个网络接口监听，如果不指定，那么会搜索所有的网络接口，在数字最小的网络端口上监听
  //也就是tcpdump -D  上左边数字最小的
  #tcpdump -i en2   
    
  //linux 2.2以上支持 -i any
  #tcpdump -i any     可以监听所有端口
  
  -n   不要把ip转换为机器名字
  #tcpdump -n

  // -w -     // -w为把内容write到某个地方， -表示标准输出  也就是输出到标准输出中
  #tcpdump  -w - |strings    这是一个超级有用的命令,把包的数据，用字符展示出来


  // -w a.cap   把抓包结果写入a.cap中
  // -C 1      如果a.cap 超过1M 大小，则新开一个文件，  －C fileSize , 单位是MB
  #tcpdump  -C 1  -w a.cap
  #ll
    -rw-r--r--   1 root  wheel  1000092 Apr 21 21:05 a.cap    //超过1MB了
    -rw-r--r--   1 root  wheel   849388 Apr 21 21:05 a.cap1


  //-r 从某个文件读取
  #tcpdump -n -r a.cap  
  
  
  #tcpdump -X    以十六进制以及ASCII的形式打印数据内容
  
  #tcpdump -x     除了打印出header外，还打印packet里面的数据(十六进制的形式)
  
  
  #tcpdump -xx  以十六进制的形式打印header, data内容

  // －A  把每一个packet都用以ASCII的形式打印出来
  ＃tcpdump -A  host www.itshouce.com.cn   


  // -c 3 表示收到3个packet就退出
  #tcpdump -A -c 3  host www.itshouce.com.cn
    ...
    3 packets captured
    65 packets received by filter
    0 packets dropped by kernel


  //看目前机器上有哪些网络接口
  #tcpdump -D
    1.en0
    2.awdl0
    3.bridge0
    4.utun0
    5.en1
    6.en2
    7.p2p0
    8.lo0


  //-e  把连接层的头打印出来
  #tcpdump -e
    21:15:27.665159 *:*:60:dc:d0:d9 (oui Unknown) > *:*:07:10:81:36 (oui Unknown), ethertype IPv4 (0x0800), length 79: zj-db0355dembp.lan.51318 > hiwifi.lan.domain: 20430+ A? www.itshouce.com.cn. (37)


  #tcpdump -j timestamp type   可以修改输出的时间格式，貌似centos6.5不支持

  #tcpdump -J  显示支持的时间格式


  //-l  把stdout bufferd住，当你既想在屏幕上看结果，又想把结果输出到文件中时，比较有用
  #tcpdump -l 
   
  //tee是一个命令，在屏幕上显示dump内容，并把内容输出到dump.log中  
  #tcpdump -l |tee dump.log       


  #tcpdump -l > dump.log &tail -f dump.log  


  //-q 就是quiect output, 尽量少的打印一些信息
  #tcpdump -q 


  //-S  打印真实的，绝对的tcp seq no
  #tcpdump -S
    21:33:06.569478 IP *dembp.lan.54864 > ***: Flags [P.], seq 3980049501:3980049596, ack 3916671858, win 4091, options [nop,nop,TS val 1201572125 ecr 1490447193], length 95

  //默认抓取包长度是65535，
  #tcpdump         //capture sieze 65535
    listening on em1, link-type EN10MB (Ethernet), capture size 65535 bytes

  //我们设置为256 该参数目的：减少抓包文件的大小
  #tcpdump -s  256    
    listening on pktap, link-type PKTAP (Packet Tap), capture size 256 bytes


  #tcpdump -t   不要打时间戳


  #tcpudmp -tt   打出timstamp,从1970-1-1 以来的秒数，以及微秒数


  #tcpdump -v    打印出详细结果  如ttl


  #tcpdump -vv   打印出更加详细的结果  如window, checksum等


tcpdump过滤项

  下面所有测试中都有 -i any的选项，表示抓取所有网络接口上的包，只是为了让测试方便
  
  //抓取arp协议的包，然后host为192.168.199.*  测试时需要在另一个session，做一个ifconfig指令
  //arp可以换为tcp,udp等
  #tcpudmp -i any -n arp host 192.168.199  
    22:39:58.991043 ARP, Request who-has 192.168.199.125 tell 192.168.199.1, length 28
    22:39:58.991059 ARP, Reply 192.168.199.125 is-at a4:5e:60:dc:d0:d9, length 28


  //抓取访问destination 80端口的包，然后我们做一个curl www.baidu.com的操作
  #tcpdump -i any -n dst port 80
  22:53:06.041382 IP 192.168.199.125.63161 > 119.75.219.45.80: Flags [F.], seq 0, ack 1, win 65535, length 0

  //抓取源上端口是80的包
  #tcpdump -i any -n src port 80     
    22:57:48.343422 IP 112.80.248.73.80 > 192.168.199.125.63275: Flags [.], seq 38478:39918, ack 78, win 193, length 1440


  //抓取源或者目标端口都是80的包
  #tcpdump -i any -n port 80    
    22:58:51.165333 IP 112.80.248.74.80 > 192.168.199.125.63298: Flags [F.], seq 100439, ack 79, win 193, length 0
    22:58:51.165349 IP 192.168.199.125.63298 > 112.80.248.74.80: Flags [R], seq 703147494, win 0, length 0


  //表示抓取destination prot 在1到80之间的端口的数据
  #tcpdump  -i any -n dst portrange 1-80   在另外的面做curl www.baidu.com   以及  telnet 192.168.21.1 
    23:00:13.550006 IP 192.168.199.125.63310 > ＊.＊.248.73.80: Flags [.], ack 71649, win 8012, length 0
    23:01:27.363723 IP 192.168.199.125.63327 > 192.168.21.1.23: Flags [S], seq 621213649, win 65535, options [mss 1460,nop,wscale 5,nop,nop,TS val 1240986522 ecr 0,sackOK,eol], length 0


  //抓取源的端口是20-80的包
  #tcpdump -i any -n src portrange 20-80  


  //抓取端口是20-80的包，不考虑源
  #tcpdump -i any -n portrange 20-80  
  
   
  //抓取destination为www.baidu.com的包
  #tcpdump -i any dst www.baidu.com    然后ping www.baidu.com ,以及 在浏览器中访问www.baidu.com
    22:22:17.445872 IP *0355dembp.lan > 112.80.248.73: ICMP echo request, id 26478, seq 0, length 64
    2:22:50.108236 IP  *0355dembp.lan.62371 > 112.80.248.74.https: Flags [S], seq 2884215363, win 65535, options [mss 1460,nop,wscale 5,nop,nop,TS val 1238683151 ecr 0,sackOK,eol], length 0


  //抓取destination为192.168.1.2的包
  #tcpdump -i any dst 192.168.1.2
    22:26:46.808706 IP zj-db0355dembp.lan > 192.168.1.2: ICMP echo request, id 31854, seq 0, length 64


  //抓取destination为192.168.1.[0-255]的包
  #tcpdump -i any dst 192.168.1    可以指定范围


  #ifconfig  可以看出我本机的ip是192.168.199.125
  //抓取source为192.168.*.*的包, 使用-n 则只是为了显示ip，而不是主机名, 
  #tcpdump -i any -n src 192.168    
    22:30:50.490355 IP 192.168.199.125.61086 > *.*.*.*.341: Flags [.], ack 56, win 8185, options [nop,nop,TS val 1239157627 ecr 1580310986], length 0


  //抓取192.168的包(不管是source还是destination )
  #tcpdump -i any -n host 192.168     
    22:38:07.580567 IP *.*.*.*.34186 > 192.168.199.125.61086: Flags [P.], seq 787907565:787907668, ack 871423065, win 126, options [nop,nop,TS val 1580748123 ecr 1239593243], length 103
    22:38:08.453788 IP 192.168.199.125.61086 > *.*.*.*.34186: Flags [P.], seq 9481:10147, ack 5769, win 8179, options [nop,nop,TS val 1239594178 ecr 1580748994], length 666


  //抓取包长度小于800的包
  #tcpudmp -i any -n less 800 
    21:09:17.687673 IP 192.168.199.1.50150 > *.*.*.*.1900: UDP, length 385


  //抓取包长度大于800的包
  #tcpdump -i any -n greater 800   
    21:13:21.801351 IP 192.168.199.125.64826 > *.*.*.*.80: Flags [P.], seq 2155:3267, ack 44930, win 8192, length 1112

  
  //只抓取tcp包
  #tcpdump -i any -n tcp   
    1:21:18.777815 IP 192.168.199.125.50249 > *.*.*.*.443: Flags [.], ack 75, win 4093, options [nop,nop,TS val 1269008649 ecr 44997038], length 0


  //只抓取udp包
  #tcpdump -i any -n udp  
    21:22:48.434449 IP 192.168.199.1.50150 > *.*.*.*.1900: UDP, length 385


  //只抓取icmp的包,internet控制包
  #tcpdump -i any -n icmp   
    21:25:42.550374 IP 192.168.199.1 > 192.168.199.125: ICMP *.*.*.* unreachable - need to frag (mtu 1480), length 556
```

参考文档：

http://www.itshouce.com.cn/linux/linux-tcpdump.html


https://www.cnblogs.com/qiumingcheng/p/8075283.html  tcpdump非常实用的抓包实例 
