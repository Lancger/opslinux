```
dd if=/dev/zero of=loadfile bs=1M count=4096

while true; do /bin/cp -f loadfile loadfile1; done &


2 内存负荷模拟：通过在内存中创建文件系统然后往里面写文件来实现的

首先，创建一个挂载点，然后将 ramfs 文件系统挂载上去：

    mkdir z
    mount -t ramfs ramfs z/

第二步，使用 dd 在该目录下创建文件。这里我们创建了一个 128M 的文件：

dd if=/dev/zero of=z/file bs=1M count=128

第三步，测试完，恢复内存

    rm z/file
    umount z
    rmdir z

```

参考文档：

https://blog.csdn.net/heavenmark/article/details/82805260

https://blog.csdn.net/Man_In_The_Night/article/details/90521966


