```
1、问题现象：
ERROR: rtslib-fb 2.1.69 has requirement pyudev>=0.16.1, but you'll have pyudev 0.15 which is incompatible.
ERROR: ipapython 4.6.5 has requirement dnspython>=1.15, but you'll have dnspython 1.12.0 which is incompatible.
ERROR: ipapython 4.6.5 has requirement python-ldap>=3.0.0b1, but you'll have python-ldap 2.4.15 which is incompatible.


2、解决办法：（忽略旧版本，强制安装 --ignore-installed）
pip install --ignore-installed rtslib-fb dnspython python-ldap pyudev -i https://mirrors.aliyun.com/pypi/simple/
```
参考资料：

https://blog.csdn.net/qq_33733970/article/details/83111772
