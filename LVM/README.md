
# 参考资料：

https://help.aliyun.com/knowledge_detail/38061.html?spm=5176.11065259.1996646101.searchclickresult.551521e8mN9JMW&aly_as=7_tCZbP-   ECS Linux LVM磁盘原地扩容


https://yq.aliyun.com/articles/52222?spm=5176.11065265.1996646101.searchclickresult.1546247dUlgfe4  


https://www.cnblogs.com/zhenglisai/p/6638107.html  新添加一块硬盘制作LVM卷并进行分区挂载


https://blog.csdn.net/qq_24871519/article/details/86243571 记一次centos7 下根目录扩容操作


https://help.aliyun.com/knowledge_detail/38061.html  ECS Linux LVM磁盘原地扩容


https://blog.csdn.net/scun_cg/article/details/82423611  阿里云centos7服务器LVM扩容实战（可行）


fdisk -l /dev/xvdb此时有2个分区，分别是/dev/xvdb1和/dev/xvdb2


将新增的分区加入到卷组中，vgdisplay可以看到Free PE有多出来
vgextend vg_group /dev/vdb2   先扩容VG


lvextend -L +100G /dev/vg_group/vg_data  lvextend扩展逻辑卷的空间大小


xfs_growfs /dev/vg_group/vg_data
