## Linux 系统安装  RabbitMQ 服务

**RabbitMQ** 是由 LShift 提供的一个 Advanced Message Queuing Protocol (AMQP) 的开源实现，由以高性能、健壮以及可伸缩性出名的 Erlang 开发设计，因此也是继承了这些优点。

本文档旨在基于 Erlang 环境在 CentOS 7 系统上安装配置 RabbitMQ 

因为 RabbitMQ 是用 Erlang 开发实现的，所以在安装 RabbitMQ 之前需要先配置完成 Erlang 的开发环境，Erlang 的具体安装配置可以参考 [rabbitmq-erlang-installation](https://github.com/yeaheo/hello-linux/blob/master/rabbitmq/rabbitmq-erlang-installation.md)。

本次安装系统环境及版本如下所示：

```bash
$ cat /etc/redhat-release
CentOS Linux release 7.5.1804 (Core)

$ uname -r
3.10.0-862.el7.x86_64

Erlang : 21.1
RabbitMQ: v3.7.9
```

为了安装方便，本次安装方式选用 yum 的方式安装。

> erlang 与 centos，rabbitmq 与 erlang，这些都是有依赖关系的，不同版本会存在不兼容性，可能导致安装完成后无法启动的情况，如果遇到此情况，可以查看官方版本兼容性文档，rabbitmq 官方给出的与 erlang/OTP 的版本兼容要求可以参考 http://www.rabbitmq.com/which-erlang.htm

RabbitMQ 的官方站点：<https://www.rabbitmq.com>

RabbitMQ 的官方下载地址：<https://www.rabbitmq.com/download.html>

本次我们在  CentOS 7 上安装 RabbitMQ 服务，更为详细的或者其他系统的安装过程可以参考官方文档：<https://www.rabbitmq.com/download.html>

### 下载 RabbitMQ 软件包

```bash
cd /usr/local/src/

#下载地址
https://github.com/rabbitmq/rabbitmq-server/releases/tag/rabbitmq_v3_6_15

wget https://github.com/rabbitmq/rabbitmq-server/releases/download/rabbitmq_v3_6_15/rabbitmq-server-3.6.15-1.el7.noarch.rpm
```

### 安装 RabbitMQ

```bash
yum install rabbitmq-server-3.6.15-1.el7.noarch.rpm -y
```

> 有时侯在安装的过程中会报错，这个可能是由于 RabbitMQ 和 Erlang 的版本问题，当我们遇到相关错误的时候，可以尝试更换版本。

### 启动相关服务

```bash
systemctl restart rabbitmq-server
systemctl enable rabbitmq-server
```

检查 RabbitMQ 服务的状态:

```bash
rabbitmqctl status
```

当 RabbitMQ 服务正常启动后，我们可以查看对应的日志，日志默认在 `/var/log/rabbitmq/`目录下。日志中给出了rabbitmq 启动的重要信息，如 node 名，$home 目录，cookie hash 值，日志文件，数据存储目录等，但是默认情况下没有配置文件的相关信息，我们需要手动创建配置文件

### 准备 RabbitMQ 配置文件

首先需要手动创建 `/etc/rabbitmq` 目录，然后把配置文件模板复制到此目录下：

```bash
mkdir /etc/rabbitmq
cp /usr/share/doc/rabbitmq-server-3.6.15/rabbitmq.config.example /etc/rabbitmq/rabbitmq.config
```

配置文件准备好后，就可以重启服务了：

```bash
systemctl restart rabbitmq-server.service
```

> 另外还可以建环境配置文件：`/etc/rabbitmq/rabbitmq-env.conf`

```
mkdir -p /data0/rabbitmq/mnesia /data0/rabbitmq/log
chown -R rabbitmq:rabbitmq /data0/rabbitmq/

#cat rabbitmq-env.conf 

RABBITMQ_MNESIA_BASE=/data0/rabbitmq/mnesia
RABBITMQ_LOG_BASE=/data0/rabbitmq/log
```

### 安装 web 插件

management plugin 默认就在 RabbitMQ 的发布版本中，enable即可：

```bash
$ rabbitmq-plugins enable rabbitmq_management
$ chown -R rabbitmq:rabbitmq /var/lib/rabbitmq/
```

安装完成后在浏览器访问 web ui：<http://ip-address:15672/>

> 默认登陆账号密码均为 `guest` ,当我们首次登陆的时候会报错，报错信息类似：`User can only log in via localhost`

在这里 我们需要创建一个新的管理员账号：

```bash
# “rabbitmqctl add_user”添加账号，并设置密码
$ rabbitmqctl add_user mqadmin mqadmin

# ”rabbitmqctl set_user_tags”设置账号的状态
$ rabbitmqctl set_user_tags mqadmin administrator

# “rabbitmqctl set_permissions”设置账号的权限
$ rabbitmqctl set_permissions -p / mqadmin ".*" ".*" ".*"

# “rabbitmqctl list_users”列出账号
$ rabbitmqctl list_users
```

至此，就可以用新建的管理员账号登陆 WEB 页面了。

参考文档：

https://github.com/yeaheo/hello-linux/blob/master/rabbitmq/rabbitmq-single-installation.md  Linux 系统安装 RabbitMQ 服务
