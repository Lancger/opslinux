## Linux 系统安装 Erlang 环境

Erlang 是一种多用途编程语言，主要用于开发并发和分布式系统。它最初是一种专有的编程语言，Ericsson 使用它来开发电话和通信应用程序。

本文档旨在在 CentOS 7 系统上安装配置 Erlang 环境，因为 RabbitMQ 是基于 Erlang 开发设计的，所以本文档主要服务于后续 RabbitMQ 的安装和配置。

其他系统的安装配置可以参考 Erlang 的官方站点相关文档：<https://www.erlang.org>

Erlang 官方库文件参见[Erlang repository page](https://packages.erlang-solutions.com/erlang/), 我们需要根据我们的需要下载对应的版本。本次我们选择用 rpm 的方式安装。

系统基本环境如下：

```bash
$ cat /etc/redhat-release
CentOS Linux release 7.5.1804 (Core)

$ uname -r
3.10.0-862.el7.x86_64
```

下载基本依赖软件：

```bash
yum update -y
yum install epel-release -y
yum install -y gcc gcc-c++ glibc-devel make ncurses-devel openssl-devel autoconf git wget wxBase.x86_64
yum install -y unixODBC unixODBC-devel wxBase wxGTK SDL wxGTK-gl
```

下载 Erlang 软件：

```bash
https://github.com/rabbitmq/erlang-rpm/releases/tag/v20.3.8.20

cd /usr/local/src/

wget https://github.com/rabbitmq/erlang-rpm/releases/download/v20.3.8.20/erlang-20.3.8.20-1.el7.x86_64.rpm
```

安装 Erlang：

```bash
rpm -Uvh erlang-20.3.8.20-1.el7.x86_64.rpm
```

等待安装完成即可。

Erlang 安装完成后，可以用如下命令检查其版本：

```bash
$ erl
Erlang/OTP 21 [erts-10.1] [source] [64-bit] [smp:1:1] [ds:1:1:10] [async-threads:1] [hipe]

Eshell V10.1  (abort with ^G)
1>
```

这样，我们已经成功安装了 Erlang。


参考文档：

https://github.com/yeaheo/hello-linux/blob/master/rabbitmq/rabbitmq-erlang-installation.md  Linux 系统安装 Erlang 环境

https://blog.csdn.net/lixiang987654321/article/details/81233843  报错依赖库问题

https://www.cnblogs.com/centos2017/p/10451411.html  
