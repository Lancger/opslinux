# 1.使用cython保护python的代码

```
先安装cython
pip uninstall cython -y
pip install --trusted-host mirrors.aliyun.com -i https://mirrors.aliyun.com/pypi/simple/ cython

然后安装python开发包
centos系统下
yum install python-devel

然后对python代码文件进行转换：
cython hello.py --embed #把python代码转换成c代码

会生成一个名为hello.c的c语言的源文件。
然后使用gcc编译成二进制可执行文件，这时候需要制定头文件、编译选项、链接选项：

gcc `python-config --cflags` `python-config --ldflags` hello.c -o hello

如果python版本较高的话可以使用

gcc `python3-config --cflags --ldflags` hello.c -o hello
这样代码就被编译成二进制的可执行程序了。

链接错误的话试试：

gcc `python-config --cflags` -o hello hello.c  `python-config --ldflags`

```
参考资料：

https://www.jianshu.com/p/4ea3030d8d96  python源代码文件加密
