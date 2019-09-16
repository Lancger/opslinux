## 一、nfs服务端
```
#所有节点安装nfs
yum install -y nfs-common nfs-utils 

#创建nfs目录
mkdir -p /nfs/data/

#修改权限
chmod -R 666 /nfs/data

#编辑export文件
vim /etc/exports
/nfs/data *(rw,no_root_squash,sync)

#配置生效
exportfs -r

#查看生效
exportfs

#启动rpcbind、nfs服务
systemctl restart rpcbind && systemctl enable rpcbind
systemctl restart nfs && systemctl enable nfs

#查看 RPC 服务的注册状况
rpcinfo -p localhost

#showmount测试
showmount -e 192.168.56.11
```

## 二、nfs客户端
```
yum install -y nfs-utils 
```

## 三、挂载nfs
```
#客户端创建目录，然后执行挂载
mkdir -p /mnt/nfs

mount -t nfs 192.168.56.11:/nfs/data  /mnt/nfs

#或者直接写到/etc/fstab文件中
vim /etc/fstab
192.168.56.11:/nfs/data /mnt/nfs/ nfs auto,noatime,nolock,bg,nfsvers=4,intr,tcp,actimeo=1800 0 0

mount -a挂载
```

参考文档：

https://yq.aliyun.com/articles/694065


https://www.crifan.com/linux_fstab_and_mount_nfs_syntax_and_parameter_meaning/  Linux中fstab的语法和参数含义和mount NFS时相关参数含义
