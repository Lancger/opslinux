# 一、工具安装
```
yum install -y https://repo.percona.com/yum/percona-release-latest.noarch.rpm

yum install -y percona-toolkit
```
# 二、表数据一致性校验(注意主库上执行)
```
pt-table-checksum --nocheck-replication-filters --no-check-binlog-format --replicate=test.checksums --empty-replicate-table --databases=user_center --tables=coin_change h=172.16.15.12,u=root,p='****',P=3306

--empty-replicate-table：检验前先清空以前的检验数据
--create-replicate-table：存放检验数据的表如果不存在，则自动创建 
```

# 三、表结构和数据同步(注意从库上执行)
```
pt-table-sync --sync-to-master h=192.168.56.12,P=3306,u=root,p=123456 --databases=center --charset=utf8 --print  > diff.sql


pt-table-sync --sync-to-master h=192.168.56.12,u=root,p='123456',P=3306 --print

pt-table-sync --sync-to-master h=192.168.56.12,u=root,p='123456',P=3306 --execute
```


参考资料：

https://www.ywnds.com/?p=4415  使用pt-table-checksum&pt-table-sync检查和修复主从数据一致性
