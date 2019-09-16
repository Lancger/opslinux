iperf是一种命令行工具，用于通过测量服务器可以处理的最大网络吞吐量来诊断网络速度问题。它在遇到网络速度问题时特别有用，通过该工具可以确定哪个服务器无法达到最大吞吐量。

```
开始之前

    您需要root权限具有sudo权限的用户帐户。
    update 系统源

安装iperf

    该iperf软件包在大多数Linux发行版的存储库中

Debian和Ubuntu安装

apt-get update
apt-get install iperf

CentOS 安装

    CentOS存储库没有iperf，使用EPEL存储库，它是用于在Redhat系统上安装第三方软件包的存储库

yum install epel-release
yum update
yum install iperf

如何使用iperf

    必须在测试的两台计算机上同时安装iPerf。如果在个人计算机上使用基于Unix或 Linux的操作系统，则可以在本地计算机上安装iPerf。

    但是，如果要测试网络提供商的吞吐量，最好使用另一台服务器作为终点，因为本地ISP可能会施加影响测试结果的网络限制。

TCP客户端和服务器

iperf需要两个系统，因为一个系统必须充当服务端，另外一个系统充当客户端，客户端连接到需要测试速度的服务端
  1.在需要测试的电脑上，以服务器模式启动iperf

iperf -s

可以看到类似于下图的输出

------------------------------------------------------------
Server listening on TCP port 5001
TCP window size: 85.3 KByte (default)
------------------------------------------------------------

2.在第二台电脑上，以客户端模式启动iperf连接到第一台电脑，替换198.51.100.5为地台电脑的ip地址

iperf -c 198.51.100.5

------------------------------------------------------------
Client connecting to 198.51.100.5, TCP port 5001
TCP window size: 45.0 KByte (default)
------------------------------------------------------------
[ 3] local 198.51.100.6 port 50616 connected with 198.51.100.5 port 5001
[ ID] Interval Transfer Bandwidth
[ 3] 0.0-10.1 sec 1.27 GBytes 1.08 Gbits/sec

3.这时可以在第一步中的服务端终端看到连接和结果，类似下图

------------------------------------------------------------
Server listening on TCP port 5001
TCP window size: 85.3 KByte (default)
------------------------------------------------------------
[ 4] local 198.51.100.5 port 5001 connected with 198.51.100.6 port 50616
[ ID] Interval Transfer Bandwidth
[ 4] 0.0-10.1 sec 1.27 GBytes 1.08 Gbits/sec

4.要停止iperf服务进程，请按CTRL+c.
UDP客户端和服务器

使用iperf，还可以测试通过UDP连接实现的最大吞吐量
1.启动UDP iperf服务

iperf -s -u

------------------------------------------------------------
Server listening on UDP port 5001
Receiving 1470 byte datagrams
UDP buffer size: 208 KByte (default)
------------------------------------------------------------

2.将客户端连接到iperf UDP服务器，替换198.51.100.5为服务端ip地址

iperf -c 198.51.100.5 -u

------------------------------------------------------------
Client connecting to 198.51.100.5, UDP port 5001
Sending 1470 byte datagrams
UDP buffer size: 208 KByte (default)
------------------------------------------------------------
[ 3] local 198.51.100.6 port 58070 connected with 198.51.100.5 port 5001
[ ID] Interval Transfer Bandwidth
[ 3] 0.0-10.0 sec 1.25 MBytes 1.05 Mbits/sec
[ 3] Sent 893 datagrams
[ 3] Server Report:
[ 3] 0.0-10.0 sec 1.25 MBytes 1.05 Mbits/sec 0.084 ms 0/ 893 (0%)

    1.05Mbits/sec远低于TCP测试中观察到的值，它也远远低于1GB 的最大出站贷款上限，这是因为默认情况下，iperf讲UDP客户端的贷款限制为每秒1Mbit。
    3.可以用-b标志更改此值，讲数字替换为要测试的最大带宽速率。如果需要测试网络速度，可以将数字设置为高于网络提供商提供的最大带宽上线：

iperf -c 198.51.100.5 -u -b 1000m

    这将告诉客户端我们希望尽可能达到每秒1000Mbits的最大值，该-b标志仅在使用UDP连接时有效，因为iperf未在TCP客户端上设置带宽限制。

------------------------------------------------------------
Client connecting to 198.51.100.5, UDP port 5001
Sending 1470 byte datagrams
UDP buffer size: 208 KByte (default)
------------------------------------------------------------
[ 3] local 198.51.100.5 port 52308 connected with 198.51.100.5 port 5001
[ ID] Interval Transfer Bandwidth
[ 3] 0.0-10.0 sec 966 MBytes 810 Mbits/sec
[ 3] Sent 688897 datagrams
[ 3] Server Report:
[ 3] 0.0-10.0 sec 966 MBytes 810 Mbits/sec 0.001 ms 0/688896 (0%)
[ 3] 0.0-10.0 sec 1 datagrams received out-of-order

通过上面可以发现这次测试结果相当高。
双向测试

-在某些情况下，可能希望测试两台服务器以获得最大吞吐量。使用iperf提供的内置双向测试功能可以轻松完成此测试。

    要测试两个连接，从客户端运行一下命令，替换ip为服务端ip地址

iperf -c 198.51.100.5 -d

    结果是iperf将在客户端服务器上启动服务器和客客户端(198.51.100.6)连接。完成此操作后，iperf会将iperf服务器连接到客户端，该连接现在既充当服务器连接又充当客户端连接。

------------------------------------------------------------
Server listening on TCP port 5001
TCP window size: 85.3 KByte (default)
------------------------------------------------------------
------------------------------------------------------------
Client connecting to 198.51.100.5, TCP port 5001
TCP window size: 351 KByte (default)
------------------------------------------------------------
[ 3] local 198.51.100.6 port 50618 connected with 198.51.100.5 port 5001
[ 5] local 198.51.100.6 port 5001 connected with 198.51.100.5 port 58650
[ ID] Interval Transfer Bandwidth
[ 5] 0.0-10.1 sec 1.27 GBytes 1.08 Gbits/sec
[ 3] 0.0-10.2 sec 1.28 GBytes 1.08 Gbits/sec

在服务器是哪个，可以看到：

------------------------------------------------------------
Client connecting to 198.51.100.6, TCP port 5001
TCP window size: 153 KByte (default)
------------------------------------------------------------
[ 6] local 198.51.100.5 port 58650 connected with 198.51.100.6 port 5001
[ 6] 0.0-10.1 sec 1.27 GBytes 1.08 Gbits/sec
[ 5] 0.0-10.2 sec 1.28 GBytes 1.08 Gbits/sec

选项
选项 	描述
-F 	更改运行测试的格式。例如，您可以使用-f k以每秒Kbits而不是每秒Mbits的速度获得结果。有效选项包括m（Mbits，默认），k（Kbits），K（KBytes）和M（MBytes）。
-V 	强制iPerf使用IPv6而不是IPv4。
-i 	更改带宽测试之间的间隔。例如，-i 60将每60秒生成一个新的带宽报告。默认值为零，执行一次带宽测试。
-p 	更改端口。未指定时，默认端口为5001.您必须在客户端和服务器上都使用此标志。
-B 	将iPerf绑定到特定的接口或地址。如果通过server命令传递，则将设置传入接口。如果通过client命令传递，则将设置传出接口。
```
参考文档：

https://www.jianshu.com/p/15f888309c72  使用iPerf进行网络吞吐量测试
