## 一、安装nali
```
wget https://github.com/dzxx36gyy/nali-ipip/archive/master.zip
unzip master.zip
cd nali-ipip-master/
./configure && make && make install && nali-update
```

## 二、具体用法
1、来查查SSh端口被破解的情况
```
[root@LookBack ~]# awk '/Failed/{a[b[$(NF-3)]++]}END{for(i=length(a);i>0;i--)for(j in b)if(b[j]==i){c++;if(c<=30)print "暴 力.解SSH密码IP:"j,"破解次数:"i}}' /var/log/secure | nali
暴力破解SSH密码IP:212.48.75.238[以色列] 破解次数:15424
暴力破解SSH密码IP:45.114.11.23[美国] 破解次数:4818
暴力破解SSH密码IP:45.114.11.51[美国] 破解次数:4215
暴力破解SSH密码IP:89.190.7.14[芬兰] 破解次数:4127
暴力破解SSH密码IP:218.87.111.116[江西省新余市 电信ADSL] 破解次数:3292
暴力破解SSH密码IP:37.187.126.133[欧洲和中东地区] 破解次数:3271
暴力破解SSH密码IP:45.114.11.12[美国] 破解次数:3245
暴力破解SSH密码IP:45.114.11.18[美国] 破解次数:3234
暴力破解SSH密码IP:45.114.11.45[美国] 破解次数:2521
暴力破解SSH密码IP:182.100.67.113[江西省 电信] 破解次数:2252
暴力破解SSH密码IP:220.77.227.71[韩国] 破解次数:1727
暴力破解SSH密码IP:219.139.240.231[湖北省武汉市 电信ADSL] 破解次数:1633
暴力破解SSH密码IP:177.1.214.85[巴西] 破解次数:1624
暴力破解SSH密码IP:45.114.11.52[美国] 破解次数:1618
暴力破解SSH密码IP:45.114.11.15[美国] 破解次数:1618
暴力破解SSH密码IP:45.114.11.27[美国] 破解次数:1618
暴力破解SSH密码IP:182.100.67.59[江西省 电信] 破解次数:1618
暴力破解SSH密码IP:185.15.194.158[欧洲和中东地区] 破解次数:1376
暴力破解SSH密码IP:218.65.30.23[江西省新余市 电信] 破解次数:646
暴力破解SSH密码IP:218.87.111.110[江西省新余市 电信ADSL] 破解次数:645
暴力破解SSH密码IP:45.114.11.22[美国] 破解次数:583
暴力破解SSH密码IP:137.154.65.37[澳大利亚 西悉尼大学] 破解次数:559
暴力破解SSH密码IP:45.114.11.50[美国] 破解次数:552
暴力破解SSH密码IP:5.58.75.26[欧洲和中东地区] 破解次数:445
暴力破解SSH密码IP:67.239.155.74[美国 弗吉尼亚州] 破解次数:377
暴力破解SSH密码IP:195.175.76.122[土耳其] 破解次数:357
暴力破解SSH密码IP:167.114.184.198[美国] 破解次数:311
暴力破解SSH密码IP:89.205.93.197[马其顿] 破解次数:264
暴力破解SSH密码IP:60.28.140.130[天津市 联通ADSL] 破解次数:245
暴力破解SSH密码IP:218.65.30.217[江西省新余市 电信] 破解次数:237
[root@LookBack ~]#
```
2、来看看Nginx日志IP访问情况
```
[root@LookBack ~]# awk '{a[b[$1]++]}END{for(i=length(a);i>0;i--)for(j in b)if(b[j]==i){c++;if(c<=30)print j,"访问次数:"i}}' /home/wwwlogs/mirrors.dwhd.org_nginx.log | nali
182.150.160.105[四川省成都市 电信] 访问次数:2139
112.20.190.40[江苏省南京市 移动] 访问次数:1806
115.206.28.235[浙江省杭州市 电信] 访问次数:1720
27.189.119.191[河北省廊坊市 电信] 访问次数:1486
110.80.45.177[福建省厦门市 电信] 访问次数:1426
183.37.11.213[广东省深圳市 电信] 访问次数:1421
154.118.109.248[非洲] 访问次数:1366
113.102.19.247[广东省 电信] 访问次数:1315
140.206.82.66[上海市 联通] 访问次数:1257
122.231.71.201[浙江省嘉兴市 电信ADSL] 访问次数:1226
59.55.2.107[江西省赣州市 电信ADSL] 访问次数:1224
61.159.97.204[甘肃省兰州市 电信] 访问次数:1214
180.175.169.84[上海市 电信] 访问次数:1172
111.183.61.168[湖北省武汉市 电信] 访问次数:1072
113.99.7.172[广东省 电信] 访问次数:1068
120.195.42.80[江苏省 移动] 访问次数:1066
120.193.146.73[内蒙古 移动] 访问次数:1054
116.225.99.71[上海市嘉定区 电信] 访问次数:1042
58.39.56.224[上海市松江区 电信ADSL] 访问次数:975
183.247.216.17[中国 移动] 访问次数:850
113.97.53.43[广东省深圳市 电信] 访问次数:812
222.85.69.181[河南省郑州市 电信ADSL] 访问次数:795
36.63.215.29[安徽省 电信] 访问次数:723
183.20.83.51[广东省广州市 电信] 访问次数:716
60.24.234.56[天津市 联通ADSL] 访问次数:684
222.67.210.78[上海市闵行区 电信ADSL] 访问次数:673
154.118.99.1[非洲] 访问次数:663
123.121.12.179[北京市 联通ADSL] 访问次数:659
114.92.48.70[上海市闸北区 电信] 访问次数:658
175.30.1.82[吉林省 电信] 访问次数:635
[root@LookBack ~]#
```
3、试试路由追踪
```
[root@LookBack ~]# nali-traceroute www.dwhd.org -n
traceroute to www.dwhd.org (106.186.112.35[日本]), 30 hops max, 60 byte packets
 1  94.23.12.252[法国]  0.604 ms  0.676 ms  0.730 ms
 2  91.121.131.73[法国]  1.977 ms  0.709 ms  0.883 ms
 3  91.121.128.89[法国]  4.138 ms  4.190 ms  4.179 ms
 4  178.32.135.164[法国]  73.253 ms 198.27.73.28[北美地区]  79.149 ms 213.251.130.121[法国]  4.359 ms
 5  178.32.135.218[法国]  75.500 ms  73.201 ms  75.503 ms
 6  * * *
 7  198.27.73.176[北美地区]  159.212 ms  156.561 ms  155.579 ms
 8  * * *
 9  111.87.3.25[日本]  147.195 ms 111.87.3.1[日本]  151.552 ms 111.87.3.25[日本]  148.525 ms
10  203.181.100.137[日本]  259.917 ms 203.181.100.133[日本]  250.558 ms 203.181.100.209[日本]  251.941 ms
11  124.215.194.165[日本]  250.296 ms 124.215.194.181[日本]  276.469 ms  254.136 ms
12  124.215.199.170[日本]  270.092 ms  282.510 ms  267.910 ms
13  106.186.112.35[日本]  251.100 ms !X  258.596 ms !X  251.726 ms !X
[root@LookBack ~]#
```
4、试试dig
```
[root@LookBack ~]# nali-dig www.dwhd.org
 
; <<>> DiG 9.8.2rc1-RedHat-9.8.2-0.30.rc1.el6_6.3 <<>> www.dwhd.org
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 48645
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 10
 
;; QUESTION SECTION:
;www.dwhd.org.            IN    A
 
;; ANSWER SECTION:
www.dwhd.org.        600    IN    A    106.186.112.35[日本]
 
;; AUTHORITY SECTION:
dwhd.org.        5368    IN    NS    f1g1ns2.dnspod.net.
dwhd.org.        5368    IN    NS    f1g1ns1.dnspod.net.
 
;; ADDITIONAL SECTION:
f1g1ns1.dnspod.net.    49113    IN    A    111.30.132.180[中国 移动]
f1g1ns1.dnspod.net.    49113    IN    A    113.108.80.138[广东省深圳市 电信]
f1g1ns1.dnspod.net.    49113    IN    A    125.39.208.193[天津市 联通]
f1g1ns1.dnspod.net.    49113    IN    A    180.153.9.189[上海市 电信]
f1g1ns1.dnspod.net.    49113    IN    A    182.140.167.166[四川省 电信]
f1g1ns2.dnspod.net.    95026    IN    A    101.226.30.224[上海市 电信]
f1g1ns2.dnspod.net.    95026    IN    A    112.90.82.194[广东省珠海市 联通]
f1g1ns2.dnspod.net.    95026    IN    A    115.236.137.40[浙江省杭州市 电信]
f1g1ns2.dnspod.net.    95026    IN    A    115.236.151.191[浙江省杭州市 电信]
f1g1ns2.dnspod.net.    95026    IN    A    182.140.167.188[四川省 电信]
 
;; Query time: 195 msec
;; SERVER: 213.186.33.99[法国]#53(213.186.33.99[法国])
;; WHEN: Sun Aug  2 01:47:21 2015
;; MSG SIZE  rcvd: 260
 
[root@LookBack ~]#
```
5、来试试nslookup
```
[root@LookBack ~]# nali-nslookup 94.23.12.91
Server:        213.186.33.99[法国]
Address:    213.186.33.99[法国]#53
 
Non-authoritative answer:
91.12.23.94[德国].in-addr.arpa    name = lookback.server-ovh03.awk.ovh.
 
Authoritative answers can be found from:
12.23.94.in-addr.arpa    nameserver = ns12.ovh.net.
12.23.94.in-addr.arpa    nameserver = dns12.ovh.net.
ns12.ovh.net    internet address = 213.251.128.131[法国]
ns12.ovh.net    has AAAA address 2001:41d0:1:1983::1
dns12.ovh.net    internet address = 213.251.188.131[法国]
dns12.ovh.net    has AAAA address 2001:41d0:1:4a83::1
 
[root@LookBack ~]#
```
6、来试试ping
```
[root@LookBack ~]# nali-ping www.dwhd.org -c2
PING www.dwhd.org (106.186.112.35[日本]) 56(84) bytes of data.
64 bytes from legion-jp-linone.106-186-112-35.dwhd.org (106.186.112.35[日本]): icmp_seq=1 ttl=53 time=254 ms
64 bytes from legion-jp-linone.106-186-112-35.dwhd.org (106.186.112.35[日本]): icmp_seq=2 ttl=53 time=254 ms
 
--- www.dwhd.org ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1255ms
rtt min/avg/max/mdev = 254.122/254.127/254.132/0.005 ms
[root@LookBack ~]# nali-ping www.dwhd.org -nc2
PING www.dwhd.org (106.186.112.35[日本]) 56(84) bytes of data.
64 bytes from 106.186.112.35[日本]: icmp_seq=1 ttl=53 time=254 ms
64 bytes from 106.186.112.35[日本]: icmp_seq=2 ttl=53 time=254 ms
 
--- www.dwhd.org ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1255ms
rtt min/avg/max/mdev = 254.066/254.195/254.325/0.520 ms
[root@LookBack ~]#
```
7、来试试tracepath
```
[root@LookBack ~]# nali-tracepath www.dwhd.org
 1?: [LOCALHOST]     pmtu 1500
 1:  vss-1b-6k.fr.eu (94.23.12.252[法国])                       230.143ms 
 1:  vss-1b-6k.fr.eu (94.23.12.252[法国])                       212.004ms 
 2:  rbx-g2-a9.fr.eu (91.121.131.73[法国])                        0.626ms 
 3:  ldn-5-a9.uk.eu (91.121.128.89[法国])                         4.146ms 
 4:  nwk-5-a9.nj.us (198.27.73.28[北美地区])                         79.042ms 
 5:  nwk-1-6k.nj.us (178.33.100.234[法国])                       71.743ms asymm  4 
 6:  no reply
 7:  pal-5-6k.ca.us (198.27.73.176[北美地区])                       155.515ms asymm  6 
 8:  no reply
 9:  pajbb002.kddnet.ad.jp (124.211.34.129[日本])               149.239ms 
10:  otejbb205.int-gw.kddi.ne.jp (203.181.100.133[日本])        249.348ms asymm  9 
11:  cm-fcu204.kddnet.ad.jp (124.215.194.181[日本])             263.761ms asymm 10 
12:  124.215.199.170[日本] (124.215.199.170[日本])                    269.850ms asymm 11 
13:  legion-jp-linone.106-186-112-35.dwhd.org (106.186.112.35[日本]) 270.129ms !H
     Resume: pmtu 1500 
[root@LookBack ~]# nali-tracepath www.dwhd.org -n
 1?: [LOCALHOST]     pmtu 1500
 1:  94.23.12.252[法国]    175.551ms 
 1:  94.23.12.252[法国]    142.296ms 
 2:  91.121.131.73[法国]     0.827ms 
 3:  91.121.128.89[法国]     4.070ms 
 4:  198.27.73.11[北美地区]     76.498ms 
 5:  178.32.135.218[法国]   75.443ms asymm  4 
 6:  no reply
 7:  198.27.73.176[北美地区]   155.532ms asymm  6 
 8:  no reply
 9:  111.87.3.1[日本]      156.023ms 
10:  203.181.100.137[日本] 257.811ms asymm  9 
11:  124.215.194.165[日本] 247.019ms asymm 10 
12:  124.215.199.170[日本] 286.210ms asymm 11 
13:  106.186.112.35[日本]  254.259ms !H
     Resume: pmtu 1500 
[root@LookBack ~]#
```


参考资料：

https://www.dwhd.org/20150802_014526.html  linux之安装nali本地解析IP归属实现IP详情的日志分析

https://cloud.tencent.com/developer/article/1362614  利用Nali-ipip在线工具查看域名解析/IP位置/MTR追踪路由
