# 一、工具安装
```
yum install -y https://repo.percona.com/yum/percona-release-latest.noarch.rpm

yum install -y percona-toolkit
```
# 二、表数据一致性校验
```
pt-table-checksum --replicate=percona.checksums --host=192.168.56.12 --user=root --password=123456 --nocheck-binlog-format --nocheck-plan --nocheck-replication-filters --recursion-method=dsn=D=percona,t=dsns

pt-table-checksum --nocheck-replication-filters --no-check-binlog-format --replicate=test.checksums --databases=test --tables=tt h=192.168.56.11,u=root,p='123456',P=3306
```

# 三、表结构和数据同步
```
pt-table-sync --sync-to-master h=192.168.56.12,P=3306,u=root,p=123456 --databases=center --charset=utf8 --print  > diff.sql


pt-table-sync --sync-to-master h=192.168.56.12,u=root,p='123456',P=3306 --print

pt-table-sync --sync-to-master h=192.168.56.12,u=root,p='123456',P=3306 --execute
```


参考资料：

https://www.ywnds.com/?p=4415  使用pt-table-checksum&pt-table-sync检查和修复主从数据一致性
