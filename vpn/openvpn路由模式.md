 # 一、Centos7.4 搭建 openvpn
 
openvpn有两种模式，桥接模式和路由模式：

    桥接模式相当于网关模式，只需要内网一台服务器做server段，那么客户端就可以通过server访问内网的所有服务器；

    路由模式则是一对一的关系，客户端只能访问安装了vpn server段的服务器，这里讲的是openvpn路由模式的搭建

1. 添加yum源
```shell
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
yum clean all
yum makecache
``` 
2. 安装 openvpn
```shell
yum -y install openvpn easy-rsa
```

# 二、配置easy-rsa-3.0
1. 复制文件
```
cp -r /usr/share/easy-rsa/ /etc/openvpn/easy-rsa
cd /etc/openvpn/easy-rsa/
\rm 3 3.0
cd 3.0.3/
find / -type f -name "vars.example" | xargs -i cp {} . && mv vars.example vars
```
2. 生成证书
创建一个新的PKI和CA
```
[root@localhost 3.0.3]# pwd
/etc/openvpn/easy-rsa/3.0.3
[root@localhost 3.0.3]# ./easyrsa init-pki            ------------------#创建空的pki

Note: using Easy-RSA configuration from: ./vars

init-pki complete; you may now create a CA or requests.
Your newly created PKI dir is: /etc/openvpn/easy-rsa/3.0.3/pki

[root@localhost 3.0.3]# ./easyrsa build-ca nopass     ----------------#创建新的CA，不使用密码

Note: using Easy-RSA configuration from: ./vars
Generating a 2048 bit RSA private key
......................+++
................................................+++
writing new private key to '/etc/openvpn/easy-rsa/3.0.3/pki/private/ca.key.pClvaQ1GLD'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Common Name (eg: your user, host, or server name) [Easy-RSA CA]:        ------------回车

CA creation complete and you may now import and sign cert requests.
Your new CA certificate file for publishing is at:
/etc/openvpn/easy-rsa/3.0.3/pki/ca.crt
```
3. 创建服务端证书
```
[root@localhost 3.0.3]# ./easyrsa gen-req server nopass       ------------回车

Note: using Easy-RSA configuration from: ./vars
Generating a 2048 bit RSA private key
...........................+++
..............................................................................+++
writing new private key to '/etc/openvpn/easy-rsa/3.0.3/pki/private/server.key.wy7Q0fuG6A'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Common Name (eg: your user, host, or server name) [server]:   ------------ 回车

Keypair and certificate request completed. Your files are:
req: /etc/openvpn/easy-rsa/3.0.3/pki/reqs/server.req
key: /etc/openvpn/easy-rsa/3.0.3/pki/private/server.key
```
4. 签约服务端证书
```
[root@localhost 3.0.3]# ./easyrsa sign server server   ------------ 签约服务端证书

Note: using Easy-RSA configuration from: ./vars


You are about to sign the following certificate.
Please check over the details shown below for accuracy. Note that this request
has not been cryptographically verified. Please be sure it came from a trusted
source or that you have verified the request checksum with the sender.

Request subject, to be signed as a server certificate for 3650 days:

subject=
    commonName                = server


Type the word 'yes' to continue, or any other input to abort.
  Confirm request details: yes           -------------------- yes
Using configuration from ./openssl-1.0.cnf
Check that the request matches the signature
Signature ok
The Subject's Distinguished Name is as follows
commonName            :ASN.1 12:'server'
Certificate is to be certified until Apr  7 14:54:08 2028 GMT (3650 days)

Write out database with 1 new entries
Data Base Updated

Certificate created at: /etc/openvpn/easy-rsa/3.0.3/pki/issued/server.crt
```
5. 创建Diffie-Hellman
```
[root@localhost 3.0.3]# ./easyrsa gen-dh     ----------------创建Diffie-Hellman
............................................................
DH parameters of size 2048 created at /etc/openvpn/easy-rsa/3.0.3/pki/dh.pem
```
到这里服务端的证书就创建完了，然后创建客户端的证书。

# 三、创建客户端证书
① 创建客户端key及生成证书
```
[root@localhost 3.0.3]# cd /etc/openvpn/easy-rsa/3.0.3
[root@localhost 3.0.3]# ./easyrsa gen-req rook_vpnc1 nopass

Note: using Easy-RSA configuration from: ./vars
Can't load /etc/openvpn/easy-rsa/3.0.3/pki/.rnd into RNG
139976687028032:error:2406F079:random number generator:RAND_load_file:Cannot open file:crypto/rand/randfile.c:88:Filename=/etc/openvpn/easy-rsa/3.0.3/pki/.rnd
Generating a RSA private key
.......+++++
................+++++
writing new private key to '/etc/openvpn/easy-rsa/3.0.3/pki/private/rook_vpnc1.key.l6ZKPIWzFy'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Common Name (eg: your user, host, or server name) [rook_vpnc1]:

Keypair and certificate request completed. Your files are:
req: /etc/openvpn/easy-rsa/3.0.3/pki/reqs/rook_vpnc1.req
key: /etc/openvpn/easy-rsa/3.0.3/pki/private/rook_vpnc1.key
```
② 将得到的rook_vpnc1.req导入然后签约证书
```
[root@localhost 3.0.3]# ./easyrsa import-req /etc/openvpn/easy-rsa/3.0.3/pki/reqs/rook_vpnc1.req rook_c1

Note: using Easy-RSA configuration from: ./vars

The request has been successfully imported with a short name of: rook_c1
You may now use this name to perform signing operations on this request.
```
③ 签约证书
```
[root@localhost 3.0.3]# ./easyrsa sign client rook_c1

Note: using Easy-RSA configuration from: ./vars
Extra arguments given.
rand: Use -help for summary.


You are about to sign the following certificate.
Please check over the details shown below for accuracy. Note that this request
has not been cryptographically verified. Please be sure it came from a trusted
source or that you have verified the request checksum with the sender.

Request subject, to be signed as a client certificate for 3650 days:

subject=
    commonName                = rook_vpnc1


Type the word 'yes' to continue, or any other input to abort.
  Confirm request details: yes
Using configuration from ./openssl-1.0.cnf
Can't load /etc/openvpn/easy-rsa/3.0.3/pki/.rnd into RNG
140158222518080:error:2406F079:random number generator:RAND_load_file:Cannot open file:crypto/rand/randfile.c:88:Filename=/etc/openvpn/easy-rsa/3.0.3/pki/.rnd
Check that the request matches the signature
Signature ok
The Subject's Distinguished Name is as follows
commonName            :ASN.1 12:'rook_vpnc1'
Certificate is to be certified until Dec  8 02:48:52 2028 GMT (3650 days)

Write out database with 1 new entries
Data Base Updated

Certificate created at: /etc/openvpn/easy-rsa/3.0.3/pki/issued/rook_c1.crt
```
如果要生成多套证书，重复生成客户端①②③步骤即可
```
./easyrsa gen-req rook_vpnc1 nopass
./easyrsa import-req /etc/openvpn/easy-rsa/3.0.3/pki/reqs/rook_vpnc1.req rook_c1
./easyrsa sign client rook_c1

./easyrsa gen-req rook_vpnc2 nopass
./easyrsa import-req /etc/openvpn/easy-rsa/3.0.3/pki/reqs/rook_vpnc2.req rook_c2
./easyrsa sign client rook_c2


./easyrsa gen-req rook_vpnc3 nopass
./easyrsa import-req /etc/openvpn/easy-rsa/3.0.3/pki/reqs/rook_vpnc3.req rook_c3
./easyrsa sign client rook_c3

```

# 四、整理证书

现在所有的证书都已经生成完了，下面来整理一下。
服务端所需要的文件
```
mkdir /etc/openvpn/certs
cd /etc/openvpn/certs/
cp /etc/openvpn/easy-rsa/3.0.3/pki/dh.pem .
cp /etc/openvpn/easy-rsa/3.0.3/pki/ca.crt .
cp /etc/openvpn/easy-rsa/3.0.3/pki/issued/server.crt .
cp /etc/openvpn/easy-rsa/3.0.3/pki/private/server.key .

[root@localhost certs]# ll
总用量 20
-rw-------. 1 root root 1172 4月  11 10:02 ca.crt
-rw-------. 1 root root  424 4月  11 10:03 dh.pem
-rw-------. 1 root root 4547 4月  11 10:03 server.crt
-rw-------. 1 root root 1704 4月  11 10:02 server.key
```

客户端所需的文件
```
####rook_vpnc1的操作
mkdir -p /etc/openvpn/client/rook_vpnc1/
cp /etc/openvpn/easy-rsa/3.0.3/pki/ca.crt /etc/openvpn/client/rook_vpnc1/
cp /etc/openvpn/easy-rsa/3.0.3/pki/issued/rook_c1.crt /etc/openvpn/client/rook_vpnc1/
cp /etc/openvpn/easy-rsa/3.0.3/pki/private/rook_vpnc1.key /etc/openvpn/client/rook_vpnc1/

[root@localhost rook_vpnc1]# ll
total 16
-rw------- 1 root root 1204 Dec 11 10:57 ca.crt
-rw------- 1 root root 4429 Dec 11 10:59 rook_c1.crt
-rw------- 1 root root 1704 Dec 11 10:59 rook_vpnc1.key

####rook_vpnc2的操作
mkdir -p /etc/openvpn/client/rook_vpnc2/
cp /etc/openvpn/easy-rsa/3.0.3/pki/ca.crt /etc/openvpn/client/rook_vpnc2/
cp /etc/openvpn/easy-rsa/3.0.3/pki/issued/rook_c2.crt /etc/openvpn/client/rook_vpnc2/
cp /etc/openvpn/easy-rsa/3.0.3/pki/private/rook_vpnc2.key /etc/openvpn/client/rook_vpnc2/

[root@localhost rook_vpnc1]# ll
total 16
-rw------- 1 root root 1204 Dec 11 10:57 ca.crt
-rw------- 1 root root 4429 Dec 11 10:59 rook_c2.crt
-rw------- 1 root root 1704 Dec 11 10:59 rook_vpnc2.key
```
其实这三个文件就够了，之前全下载下来是因为方便，然而这次懒得弄了，哈哈，编写服务端配置文件。顺便提一下再添加用户在./easyrsa gen-req这里开始就行了,像是吊销用户证书的命令都自己用./easyrsa --help去看吧，GitHub项目地址
服务器配置文件
```
[root@localhost ~]# vim /etc/openvpn/server.conf
port 1194
proto tcp
dev tun
ca /etc/openvpn/certs/ca.crt
cert /etc/openvpn/certs/server.crt
key /etc/openvpn/certs/server.key
dh /etc/openvpn/certs/dh.pem 
user openvpn
group openvpn
server 10.10.100.0 255.255.255.0
client-config-dir /etc/openvpn/ccd    #为了配置固定IP
client-to-client
duplicate-cn
keepalive 10 120
comp-lzo
persist-key
persist-tun
status openvpn-status.log
log-append  openvpn.log
verb 3
```
固定ip
```
[root@localhost ccd]# ll
total 8
-rw-r--r-- 1 root root 40 Dec 11 11:35 rook_vpnc1
-rw-r--r-- 1 root root 40 Dec 11 11:08 rook_vpnc2

[root@localhost ccd]# cat rook_vpnc1 
ifconfig-push 10.10.100.21 10.10.100.22

[root@localhost ccd]# cat rook_vpnc2
ifconfig-push 10.10.200.23 10.10.200.24
```
客户端配置
```
#vim /etc/openvpn/openv_client.ovpn
client
dev tun
proto tcp
remote 23.244.61.198 1999
resolv-retry infinite
nobind
auth-nocache
persist-key
persist-tun
ca ca.crt
cert fly_c1.crt
key fly_vpnc1.key
comp-lzo
verb 4
max-routes 1000
#route 192.168.52.0 255.255.255.0 vpn_gateway
```
防火墙配置
```
[root@izuf62w1juq9pm5jar66slz ccd]# cat /etc/sysconfig/iptables
# sample configuration for iptables service
# you can edit this manually or use system-config-firewall
# please do not ask us to add additional ports/services to this default configuration
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
COMMIT
*nat
:PREROUTING ACCEPT [1:60]
:POSTROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [1:76]
-A POSTROUTING -s 10.10.100.0/24 -j MASQUERADE 
COMMIT
```
服务器需要开启转发
```
#服务器端必须开启转发
echo 1 > /proc/sys/net/ipv4/ip_forward

sysctl -w net.ipv4.ip_forward=1
```
启动服务
```
[root@localhost ~]# systemctl restart openvpn@server
```
 参考文档：
 
 https://blog.rj-bai.com/post/132.html#menu_index_11


 https://blog.rj-bai.com/post/132.html#menu_index_11   Centos7.4搭建openvpn
