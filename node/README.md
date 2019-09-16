# CentOS 7下安装 Node.js

## 一、源码安装

### 1、下载源码
    你需要在 https://nodejs.org/en/download/ 下载最新的Nodejs版本，本文v7.8.0以为例:
```bash
yum install gcc gcc-c++
cd /usr/local/src/
wget https://nodejs.org/dist/v7.8.0/node-v7.8.0.tar.gz
```

### 2、解压源码
```bash
tar -zxvf node-v7.8.0.tar.gz
```

### 3、 编译安装
```bash
cd node-v7.8.0
./configure --prefix=/usr/local/node/
make
make install
```

### 4、 配置NODE_HOME，进入profile编辑环境变量
```bash
#vim /etc/profile

#set for nodejs
export NODE_HOME=/usr/local/node/
export PATH=$NODE_HOME/bin:$PATH

:wq保存并退出，编译/etc/profile 使配置生效

source /etc/profile
###验证是否安装配置成功

node -v

输出 v7.8.0 表示配置成功 ###npm模块安装路径

/usr/local/node/lib/node_modules/

注：Nodejs 官网提供了编译好的Linux二进制包，你也可以下载下来直接应用。
```

### 二、编译好的nodejs二进制包
```bash
wget https://nodejs.org/dist/v10.15.0/node-v10.15.0-linux-x64.tar.xz
tar -xf node-v10.15.0-linux-x64.tar.xz
mv node-v10.15.0-linux-x64 /usr/local/node

#vim /etc/profile
添加
#set for nodejs
export NODE_HOME=/usr/local/node/
export PATH=$NODE_HOME/bin:$PATH

source /etc/profile

root># node -v
v7.8.0

root># npm -v
4.2.0
```

### 验证nodejs环境是否正常

    参考  http://www.runoob.com/nodejs/nodejs-http-server.html
    
### 安装cnpm

    npm install -g cnpm --registry=https://registry.npm.taobao.org

