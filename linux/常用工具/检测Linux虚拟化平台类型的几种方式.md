# 检测Linux虚拟化平台类型的几种方式


要想找出 Linux 系统运行在虚拟化平台中还是硬件服务器上，有多种方式可供大家选择，这主要取决于你的 hypervisor 或 container 环境。不同的虚拟化或容器技术会在其实例中引入不同的识别指纹，如：处理器厂商、特殊的 /proc 文件或虚拟网卡名称等。 另外通过 dmesg 显示启动序列，也可以找出 Linux 或 VPS 所使用虚拟化平台类型的一些线索。

下面我们将介绍几个命令行工具，让大家可以非常容易地检测到 Linux 所使用的虚拟化平台类型。

# 方法一：dmidecode

要检测 Linux 底层的虚拟化类型首选的就是 dmidecode 命令，它最初设计来显示系统 BIOS 和硬件组件的相关信息。使用如下命令便可以检测相关虚拟化信息：
```
sudo dmidecode -s system-manufacturer
```

# 方法二：systemd

对于使用 systemd 的 Linux 系统，可以使用 systemd-detect-virt 命令来进行检测，该命令目前可以同时检测到基于 hypervisor 的虚拟化技术（例如 KVM、QEMU、VMware、Xen、Oracle VM、VirtualBox、UML）和基于容器的虚拟化技术（例如 LXC、Docker、OpenVZ）。
```
systemd-detect-virt

注意：在物理服务器上使用该命令会输出「none」。
```

# 方法三：virt-what

我们介绍的最后一种检测 Linux 所使用虚拟化类型的方法是 virt-what 命令，virt-what 实际上是一个 Shell 脚本。它通过各种启发式方法来识别虚拟化环境类型，可以检测出 QEMU/KVM、VMware、Hyper-V、VirtualBox、OpenVZ/Virtuozzo、Xen、LXC、IBM PowerVM 以及 Parallels 等平台类型。

在使用之前，大家需要先通过 apt-get 或 yum 安装 virt-what，再执行如下命令进行检测：
```
sudo virt-what
```

参考资料：

https://www.linuxidc.com/Linux/2016-03/129539.htm
