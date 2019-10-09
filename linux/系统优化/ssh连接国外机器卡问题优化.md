最近经常连国外的服务器，出现了连不上、连上又经常断开的问题。

连不上1

发现卡在：debug1: expecting SSH2_MSG_KEX_ECDH_REPLY上，
```
$ ssh -v xxx@47.88.217.222
OpenSSH_7.9p1, LibreSSL 2.7.3
debug1: Reading configuration data /Users/shitaibin/.ssh/config
debug1: Reading configuration data /etc/ssh/ssh_config
debug1: /etc/ssh/ssh_config line 48: Applying options for *
debug1: Connecting to 47.88.217.222 [47.88.217.222] port 22.
debug1: Connection established.
debug1: identity file /Users/shitaibin/.ssh/id_rsa type 0
debug1: identity file /Users/shitaibin/.ssh/id_rsa-cert type -1
debug1: identity file /Users/shitaibin/.ssh/id_dsa type -1
debug1: identity file /Users/shitaibin/.ssh/id_dsa-cert type -1
debug1: identity file /Users/shitaibin/.ssh/id_ecdsa type -1
debug1: identity file /Users/shitaibin/.ssh/id_ecdsa-cert type -1
debug1: identity file /Users/shitaibin/.ssh/id_ed25519 type -1
debug1: identity file /Users/shitaibin/.ssh/id_ed25519-cert type -1
debug1: identity file /Users/shitaibin/.ssh/id_xmss type -1
debug1: identity file /Users/shitaibin/.ssh/id_xmss-cert type -1
debug1: Local version string SSH-2.0-OpenSSH_7.9
debug1: Remote protocol version 2.0, remote software version OpenSSH_7.2p2 Ubuntu-4ubuntu2.4
debug1: match: OpenSSH_7.2p2 Ubuntu-4ubuntu2.4 pat OpenSSH_7.0*,OpenSSH_7.1*,OpenSSH_7.2*,OpenSSH_7.3*,OpenSSH_7.4*,OpenSSH_7.5*,OpenSSH_7.6*,OpenSSH_7.7* compat 0x04000002
debug1: Authenticating to 47.88.217.222:22 as 'nameXXX'
debug1: SSH2_MSG_KEXINIT sent
debug1: SSH2_MSG_KEXINIT received
debug1: kex: algorithm: curve25519-sha256@libssh.org
debug1: kex: host key algorithm: ecdsa-sha2-nistp256
debug1: kex: server->client cipher: chacha20-poly1305@openssh.com MAC: <implicit> compression: none
debug1: kex: client->server cipher: chacha20-poly1305@openssh.com MAC: <implicit> compression: none
debug1: expecting SSH2_MSG_KEX_ECDH_REPLY
```

Google一下

    原因：MTU太大了，造成了丢包。
    方案：把MTU改小，服务器和本机最好都修改，因为无论哪一方的报文再大被丢包都会造成连接失败。

```
sudo ifconfig eth0 mtu 1200
或者
echo "1460" > /sys/class/net/eth0/mtu
```

连接断开

都是国外服务器，通信延迟有点高，ping一下，延迟都在300ms以上，经常操作着就卡住了，然后一会报错：packet_write_wait: Broken pipe。


    原因：通信不好造成连接断开。
    方案：加心跳配置。

服务器端或客户端其中一边加就行了，优先加客户端，因为我Mac经常连各种服务器：

文件：~/.ssh/config

```
ServerAliveInterval 60
```

如果服务器被多人连，服务器端也得设置：

文件： /etc/ssh/sshd_config

```
ClientAliveInterval 60
```

参考资料：

http://lessisbetter.site/2019/03/04/ssh-problems/  SSH问题记录 
