## 一、安装依赖

```bash
yum install -y git readline readline-devel gcc gcc-c++ zlib zlib-devel openssl openssl-devel sqlite-devel python-devel mysql-devel

# python3.7版本需要
yum install libffi-devel -y
```

## 二、下载并安装python3.6

```bash
cd /usr/local/src/

export VER="3.6.8"
wget https://www.python.org/ftp/python/${VER}/Python-${VER}.tgz
tar -xzf Python-${VER}.tgz 
cd Python-${VER}
./configure --prefix=/usr/local/python3.6 --enable-shared
make -j 4 && make install

# ./configure --prefix=/usr/local/python3.6 --enable-shared --enable-optimizations （测试开发环境不开启）
# --enable-shared 启用共享，方便其他依赖python的一些内置库（比如 mysqlclient) 的资源的正常安装
# –enable-optimizations 是优化选项(LTO，PGO 等)加上这个 flag 编译后，性能有 10% 左右的优化，但在初次安装构建编译速度会很慢

# ln -s /usr/local/python3.6/bin/python3.6 /usr/bin/python3
# ln -s /usr/local/python3.6/bin/pip3 /usr/bin/pip3
# ln -s /usr/local/python3.6/bin/pyvenv /usr/bin/pyvenv

# 使用环境变量方式，减少软链操作
echo "PATH=/usr/local/python3.6/bin:\$PATH" > /etc/profile.d/python368.sh
```

- 报错信息

```bash
cd /usr/local/python3.6/bin

root># ldd python3
        linux-vdso.so.1 =>  (0x00007fff84af8000)
        libpython3.6m.so.1.0 => not found      --  未找到该so文件
        libpthread.so.0 => /lib64/libpthread.so.0 (0x00007f894d8f6000)
        libdl.so.2 => /lib64/libdl.so.2 (0x00007f894d6f2000)
        libutil.so.1 => /lib64/libutil.so.1 (0x00007f894d4ef000)
        libm.so.6 => /lib64/libm.so.6 (0x00007f894d1ed000)
        libc.so.6 => /lib64/libc.so.6 (0x00007f894ce1f000)
        /lib64/ld-linux-x86-64.so.2 (0x00007f894db12000)
```

- 解决办法

```bash
# 链接库文件
cp /usr/local/python3.6/lib/libpython3.6m.so.1.0 /usr/local/lib
cd /usr/local/lib
ln -s libpython3.6m.so.1.0 libpython3.6m.so
echo '/usr/local/lib' >> /etc/ld.so.conf
/sbin/ldconfig
```

## 三、pip升级

```bash
pip3 install --upgrade pip -i https://pypi.mirrors.ustc.edu.cn/simple/

pip3 install -i https://pypi.mirrors.ustc.edu.cn/simple/  -r requirements.txt    #可用的
```

## 四、创建虚拟环境

```bash
# 推荐使用
cd /usr/local/
python3 -m venv demovenv
cd demovenv
source bin/activate

# 旧方式
cd /usr/local/
/usr/local/python3.6/bin/pyvenv demovenv
cd demovenv
source bin/activate
```

## 五、Python更改pip源

- 临时使用

```bash
pip3 install pip -i https://pypi.tuna.tsinghua.edu.cn/simple/
```

- 永久修改

```bash
mkdir -p ~/.pip

cat >~/.pip/pip.conf<<\EOF
[global]
timeout = 6000
index-url = https://mirrors.aliyun.com/pypi/simple/

[install]
trusted-host=mirrors.aliyun.com
EOF
```

- 查看pip源配置

```bash
root># pip3 config list
global.index-url='https://mirrors.aliyun.com/pypi/simple/'
install.trusted-host='mirrors.aliyun.com'
```

参考资料：

https://www.jianshu.com/p/dae202aa25b4  Python更改pip源
