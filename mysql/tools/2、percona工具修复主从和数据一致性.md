# 一、工具安装
```
yum install -y https://repo.percona.com/yum/percona-release-latest.noarch.rpm

yum install -y percona-toolkit
```
# 二、表数据一致性校验(注意主库上执行)
```
pt-table-checksum --nocheck-replication-filters --no-check-binlog-format --create-replicate-table --replicate=percona.checksums --empty-replicate-table --databases=user_center --tables=coin_change h=172.16.15.12,u=root,p='****',P=3306


h=172.16.15.12 这里是写主库
--recursion-method：查找slave的方式，有hosts和processlist两种。前者是用show slave hosts来查找，这种方式适合服务器的端口和socket之类的不使用默认参数的情况；后者是用show processlist来查找
--empty-replicate-table：检验前先清空以前的检验数据
--create-replicate-table：存放检验数据的表如果不存在，则自动创建 

Checking if all tables can be checksummed ...
Starting checksum ...
            TS ERRORS  DIFFS     ROWS  DIFF_ROWS  CHUNKS SKIPPED    TIME TABLE
06-25T15:41:59      0      0        9          0       1       0   0.236 xmusic.star_archives
06-25T15:41:59      0      0        3          0       1       0   0.337 xmusic.star_categories
06-25T15:41:59      0      0        9          0       1       0   0.153 xmusic.star_category
06-25T15:42:00      0      0        8          0       1       0   0.246 xmusic.star_news
06-25T15:42:00      0      0        0          0       1       0   0.613 xmusic.star_occupation
06-25T15:42:00      0      0      160          0       1       0   0.336 xmusic.tags
06-25T15:42:02      0      1       10          0       1       0   1.284 xmusic.type
06-25T15:42:02      0      0      102          0       1       0   0.437 xmusic.users

如果是首次运行，会在主库自动创建 percona.checksums 表。


TS ：完成检查的时间戳。
ERRORS ：检查时候发生错误和警告的数量。
DIFFS ：0表示一致，1表示不一致。当指定--no-replicate-check时，会一直为0，当指定--replicate-check-only会显示不同的信息
ROWS ：比对的表行数。
CHUNKS ：被划分到表中的块的数目。
SKIPPED ：由于错误或警告或过大，则跳过块的数目。
TIME ：执行的时间。
TABLE ：被检查的表名
```
# 从库校验
```
校验结束后，在每个从库上，执行如下的sql语句即可看到是否有主从不一致发生：

select * from percona.checksums where master_cnt <> this_cnt OR master_crc <> this_crc OR 
ISNULL(master_crc) <> ISNULL(this_crc);
```

# 三、表结构和数据同步(注意从库上执行)
```
pt-table-sync --replicate=percona.checksums --sync-to-master h=192.168.56.12,P=3306,u=root,p=123456 --databases=center --charset=utf8 --print  > diff.sql

pt-table-sync --replicate=percona.checksums --sync-to-master h=192.168.56.12,u=root,p='123456',P=3306 --print

pt-table-sync --replicate=percona.checksums --sync-to-master h=192.168.56.12,u=root,p='123456',P=3306 --execute

--sync-to-master h=192.168.56.12  注意这里是写从库的IP

--replicate=     #指定通过pt-table-checksum得到的表，这2个工具差不多都会一直用。
--databases=     #指定执行同步的数据库，多个用逗号隔开。
--tables=        #指定执行同步的表，多个用逗号隔开。
--sync-to-master #指定一个DSN，即从的IP、端口、用户、密码等，他会通过show processlist或show slave status去自动的找主。
h=192.168.56.12  #Slave服务器地址。
u=root           #帐号。
p=123456         #密码。
P=3306           #端口。
--print          #打印SQL语句,但不执行命令。
--execute        #执行命令。
```

# 四、常见问题

1、Waiting for the --replicate table to replicate to XXX

问题出在 percona.checksums 表在从库不存在，根本原因是没有从主库同步过来，所以看一下从库是否延迟严重。

```
--replicate= 指定 checksum 计算结果存到哪个库表里，如果没有指定，默认是 percona.checksums 。
但是我们检查使用的mysql用户一般是没有 create table 权限的，所以你可能需要先手动创建：

CREATE DATABASE IF NOT EXISTS percona;
CREATE TABLE IF NOT EXISTS percona.checksums (
    db CHAR(64) NOT NULL,
    tbl CHAR(64) NOT NULL,
    chunk INT NOT NULL,
    chunk_time FLOAT NULL,
    chunk_index VARCHAR(200) NULL,
    lower_boundary TEXT NULL,
    upper_boundary TEXT NULL,
    this_crc CHAR(40) NOT NULL,
    this_cnt INT NOT NULL,
    master_crc CHAR(40) NULL,
    master_cnt INT NULL,
    ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (db,tbl,chunk),
    INDEX ts_db_tbl(ts,db,tbl)
) ENGINE=InnoDB;

生产环境中数据库用户权限一般都是有严格管理的，假如连接用户是repl_user（即直接用复制用户来检查），它应该额外赋予对其它库的 SELECT ，LOCK TABLES 权限，如果后续要用 pt-table-sync 就就需要写权限了。对percona库有写权限：
```


参考资料：

https://www.ywnds.com/?p=4415  使用pt-table-checksum&pt-table-sync检查和修复主从数据一致性

https://segmentfault.com/a/1190000004309169
