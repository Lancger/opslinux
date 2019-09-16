一、背景

公司数据中心从托管机房迁移到阿里云，需要对MySQL迁移（Replication）后的数据一致性进行校验，但又不能对生产环境使用造成影响，pt-table-checksum成为了绝佳也是唯一的检查工具。所以就利用pt-table-checksum工作来检查主从的一致性，以及通过pt-table-sync如何修复这些不一致的数据。

pt-table-checksum是Percona-Toolkit的组件之一，用于检测MySQL主、从库的数据是否一致。其原理是在主库执行基于statement的sql语句来生成主库数据块的checksum，把相同的sql语句传递到从库执行，并在从库上计算相同数据块的checksum，最后，比较主从库上相同数据块的checksum值，由此判断主从数据是否一致。检测过程根据唯一索引将表按row切分为块（chunk），以为单位计算，可以避免锁表。检测时会自动判断复制延迟、 master的负载， 超过阀值后会自动将检测暂停，减小对线上服务的影响。

pt-table-checksum默认情况下可以应对绝大部分场景，官方说，即使上千个库、上万亿的行，它依然可以很好的工作，这源自于设计很简单，一次检查一个表，不需要太多的内存和多余的操作；必要时，pt-table-checksum会根据服务器负载动态改变chunk大小，减少从库的延迟。

为了减少对数据库的干预，pt-table-checksum还会自动侦测并连接到从库，当然如果失败，可以指定–recursion-method选项来告诉从库在哪里。它的易用性还体现在，复制若有延迟，在从库checksum会暂停直到赶上主库的计算时间点（也通过选项–设定一个可容忍的延迟最大值，超过这个值也认为不一致）。
二、percona-toolkit工具安装

1）软件下载：https://www.percona.com/downloads/percona-toolkit

2）安装该工具依赖的软件包

$ yum install perl-IO-Socket-SSL perl-DBD-MySQL perl-Time-HiRes perl-TermReadKey perl-IO-Socket-SSL -y

3）软件安装

$ yum localinstall percona-toolkit-2.2.18-1.noarch.rpm

三、pt-table-checksum工具使用

使用方法：

$ pt-table-checksum [OPTIONS] [DSN]

pt-table-checksum在主（master）上通过执行校验的查询对复制的一致性进行检查，对比主从的校验值，从而产生结果。DSN指向的是主的地址，该工具的退出状态不为零，如果发现有任何差别，或者如果出现任何警告或错误，更多信息请查看官方资料。

下面通过实际的例子来解释该工具如何使用：

主库（3306）和从库（3307）目前主从复制正常运行。

主库（3306）

mysql> create database test;
mysql> CREATE TABLE `tt` (
 `id` int(11) NOT NULL AUTO_INCREMENT,
 `count` int(11) DEFAULT NULL,
 PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4;

mysql> insert into test.tt values(1,1);
mysql> insert into test.tt values(2,2);
mysql> insert into test.tt values(3,3);

从库（3307）

mysql> select * from test.tt;
+----+-------+
| id | count |
+----+-------+
| 1  | 1     |
| 2  | 2     |
| 3  | 3     |
+----+-------+
3 rows in set (0.00 sec)

备库已经自动复制了主库的信息，那么为了模拟数据不一致性，我们可以往主库插入几条数据。

mysql> insert into test.tt values(4,4);
Query OK, 1 row affected (0.00 sec)

mysql> insert into test.tt values(5,5);
Query OK, 1 row affected (0.00 sec)

很明显主从数据不一致，那么我们使用工具来检测。在检测之前需要有一个前提条件，如下：

1、运行之前需要从库的同步IO和SQL进程是YES状态，因为从库要同步主库的check信息。

2、运行时只能指定一个host，必须为主库的IP。

3、在检查时会向表加S锁。

4、在两个库上都创建一个相同的用户和密码（为了方便后面的pt-table-checksum运行）。

mysql> GRANT all ON *.* TO 'root'@'%' IDENTIFIED BY '123456';
Query OK, 0 rows affected (0.00 sec)

mysql> flush privileges;
Query OK, 0 rows affected (0.00 sec)

下面开始在主库上运行pt-table-checksum工具。

$ pt-table-checksum --nocheck-replication-filters --no-check-binlog-format --replicate=test.checksums --databases=test --tables=tt h=10.0.60.143,u=root,p='123456',P=3306
Diffs cannot be detected because no slaves were found.  Please read the --recursion-method documentation for information.

参数的意思：

--nocheck-replication-filters #不检查复制过滤器，建议启用。后面可以用--databases来指定需要检查的数据库；
--no-check-binlog-format      #不检查复制的binlog模式，要是binlog模式是ROW，则会报错；
--replicate-check-only        #只显示不同步的信息；
--replicate=test.checksums    #把checksum的信息写入到指定表中,建议直接写到被检查的数据库当中；
--databases=test              #指定需要被检查的数据库，多个则用逗号隔开；
--tables=tt                   #指定需要被检查的表，多个用逗号隔开；
--socket=                     #可指定Master的socket；
h=127.0.0.1                   #Master的地址；
u=root                        #用户名（Master和Slave可共用）；
p=123456                      #密码（Master和Slave可共用）；
P=3306                        #Master的端口；

上面出现了报错信息：Diffs cannot be detected because no slaves were found.  Please read the –recursion-method documentation for information.

提示信息很清楚，因为找不到从，所以执行失败。我们需要用参数–recursion-method指定模式解决，关于–recursion-method参数的设置有：

METHOD       USES
===========  =============================================
processlist  SHOW PROCESSLIST
hosts        SHOW SLAVE HOSTS
cluster      SHOW STATUS LIKE 'wsrep\_incoming\_addresses'
dsn=DSN      DSNs from a table
none         Do not find slaves

默认是通过show processlist找到slave host的值。还有一种方法是通过show slave hosts；找到slave host的值，前提是从库配置文件里面已经配置自己的地址和端口：

$ grep 'report' /etc/my.cnf
report_host = 10.0.60.143
report_port = 3307

mysql> show slave hosts;
+-----------+-------------+------+-----------+--------------------------------------+
| Server_id | Host        | Port | Master_id | Slave_UUID                           |
+-----------+-------------+------+-----------+--------------------------------------+
|        20 | 10.0.60.143 | 3307 |        10 | 47af3f9d-af94-11e6-8b5b-001dd8b71e2b |
+-----------+-------------+------+-----------+--------------------------------------+
1 row in set (0.00 sec)

所以找不到从服务器时，在从库配置文件添加：

report_host=slave_ip

report_port=slave_port

现在我们再来检测数据一致性，我这里使用hosts方式找到从库：

$ pt-table-checksum --nocheck-replication-filters --no-check-binlog-format --replicate=test.checksums --databases=test --tables=tt h=10.0.60.143,u=root,p='123456',P=3306 --recursion-method=hosts
            TS ERRORS DIFFS  ROWS CHUNKS SKIPPED TIME TABLE
11-22T11:58:01    0     1     3    1      0    0.092 test.tt

TS：完成检查的时间。

ERRORS：检查时候发生错误和警告的数量。

DIFFS：0表示一致，1表示不一致，当指定–no-replicate-check时，会一直为0；当指定–replicate-check-only会显示不同的信息。

ROWS：表的行数。

CHUNKS：被划分到表中的块的数目。

SKIPPED：由于错误或警告或过大，则跳过块的数目。

TIME：执行的时间。

TABLE：被检查的表名。

好了，命令以及常用参数都介绍了，一起解释下上面执行的效果：

通过DIFFS是1就可以看出主从的表数据不一致。怎么不一致呢？ 通过指定–replicate=test.checksums参数，就说明把检查信息都写到了checksums表中。

进入SLAVE相应的库中查看checksums表的信息：

mysql> select * from test.checksums\G
*************************** 1. row ***************************
            db: test
           tbl: tt
         chunk: 1
    chunk_time: 0.005582
   chunk_index: NULL
lower_boundary: NULL
upper_boundary: NULL
      this_crc: 699fed16
      this_cnt: 3
    master_crc: 699fed16
    master_cnt: 3
            ts: 2016-11-22 13:25:16
1 row in set (0.00 sec)

通过上面找到了这些不一致的数据表，如何同步数据呢？即如何修复MySQL主从不一致的数据，让他们保持一致性呢？利用另外一个工具pt-table-sync。
四、pt-table-sync工具使用

使用方法：

$ pt-table-sync [OPTIONS] DSN [DSN]

pt-table-sync高效的同步MySQL表之间的数据，他可以做单向和双向同步的表数据。他可以同步单个表，也可以同步整个库。它不同步表结构、索引、或任何其他模式对象。所以在修复一致性之前需要保证他们表存在。需要注意的是这个命令需要在Slave从库执行。

接着上面的复制情况，主和从的tt表数据不一致，需要修复。我们连接从库开始执行pt-table-sync，使用print参数，他会在屏幕显示修复的SQL语句。然后可以手工确认并执行。

$ pt-table-sync --sync-to-master h=10.0.60.143,u=root,p='123456',P=3307 --print

参数的意义：

--replicate=     #指定通过pt-table-checksum得到的表，这2个工具差不多都会一直用。
--databases=     #指定执行同步的数据库，多个用逗号隔开。
--tables=        #指定执行同步的表，多个用逗号隔开。
--sync-to-master #指定一个DSN，即从的IP、端口、用户、密码等，他会通过show processlist或show slave status去自动的找主。
h=10.0.60.143    #Slave服务器地址。
u=root           #帐号。
p=123456         #密码。
P=3307           #端口。
--print          #打印SQL语句,但不执行命令。
--execute        #执行命令。

也可以通过这个命令自动执行，不过这样会修改从库的数据，感觉不是太安全。

$ pt-table-sync --sync-to-master h=10.0.60.143,u=root,p='123456',P=3307 --execute

此时应该已经修复了从库的数据，然后检查主从数据的一致性验证一下：

$ pt-table-checksum --nocheck-replication-filters --no-check-binlog-format --replicate=test.checksums --databases=test --tables=tt h=10.0.60.143,u=root,p=123456,P=3306 --recursion-method=hosts
            TS ERRORS  DIFFS     ROWS  CHUNKS SKIPPED    TIME TABLE
04-13T16:27:28      0      0        3       1       0   0.097 test.tt

主库（3306）：

mysql> select * from test.tt;
+----+-------+
| id | count |
+----+-------+
| 1 | 1 |
| 2 | 2 |
| 3 | 3 |
+----+-------+
3 rows in set (0.00 sec)

从库（3307）：

mysql> select * from test.tt;
+----+-------+
| id | count |
+----+-------+
| 1 | 1 |
| 2 | 2 |
| 3 | 3 |
+----+-------+
3 rows in set (0.00 sec)

OK，数据已经保持一致了。不过建议还是用–print打印出来的好，这样就可以知道那些数据有问题，可以人为的干预下。不然直接执行了，出现问题之后更不好处理。总之还是在处理之前做好数据的备份工作。

注意：要是表中没有唯一索引或则主键则会报错：

Can't make changes on the master because no unique index exists at /usr/local/bin/pt-table-sync line 10591.

五、基本工作原理

5.1 pt-table-checksum工作原理

Step1: 在Master主库执行pt-table-checksum命令。首先对比主库和的从库的表结构进行检查，如果结构不一致则报错，停止修复。

Step2: 如果一行一行去比较，效率会很低，所以pt-table-checksum会根据表的索引，将表分成一个一个的chunk，每个chunk默认1000行，这个值可以根据服务器性能进行调整。

Step3: 将每个chunk中的每一行的所有列都转化为字符串，并用concat_ws()函数将所有列拼接起来的到一个大的”总字符串“，之后我们用BIT_XOR()聚合函数将每个chunk的所有行的”总字符串“进行组合拼接，之后计算出整个chunk的crc32校验核（checksum值）。

Step4: 在从库上执行Step3同样的操作，计算出从库表各个chunk的checksum值。

Step5: 将主库中表的各个chunk块的checkum值和从库表的各个chunk块checksum值都存储在replicate参数指定的checksum结果表中。（都在从库中）

Step6: 检测完毕，我们去检查从库的replicate参数指定的checksum结果表就可以了。master_src列和master_cnt列代表主库，this_src列和this_cnt列代表从库。

注意：Step3在计算checksum时候，为了保证一致性，需要在语句中加入for update锁住具体chunk中的行，会有阻塞产生。如果是MyISAM这类不支持事务的表，则会锁表。

主要函数：使用concat_ws函数将数据合并为一行，然后使用crc32函数生成校验码，最后将其插入到指定的checksums表中。

mysql> select concat_ws(',',id,count) from tt;
+-------------------------+
| concat_ws(',',id,count) |
+-------------------------+
| 1,1                     |
| 2,2                     |
| 3,3                     |
+-------------------------+
3 rows in set (0.00 sec)

mysql> select crc32(concat_ws(',',id,count)) from test.tt;
+--------------------------------+
| crc32(concat_ws(',',id,count)) |
+--------------------------------+
|                     2986818849 |
|                      692638402 |
|                     1603111011 |
+--------------------------------+
3 rows in set (0.00 sec)

5.2 pt-table-sync工作原理

Step1: 首先，定位到每个database中的每个表中的每一个chunk，发现有不一致的chunk后，查询主库的show master status。之后在从库执行select master_pos_wait(‘主库当前binglog日志名’,’主库当前binlog日志位置’);该步骤的目的主要是阻塞从库，使其达到主库的二进制日志位置，从而主从同步。

Step2: 过滤不一致chunk中的每一行，依然采用checksum来比较其是否不一致。检测到不一致后进行记录。

Step3: 将不一致的行，在主库转化为replace into语句（此语句会将主键不存在数据插入到表中，主键重复的进行update），通过binlog传播到从库，并在从库执行。

Step4: 如此往复，将所有的数据库、表和每个chunk的每一行进行修复。

另外，有一些注意事项：

1）pt-table-checksum工具检查的表可以没有主键或者唯一索引。

2）pt-table-sync工具修复表的时候，表必须有主键或者唯一索引。

3）两个工具在运行的过程中，都会产生对于chunk行块的写锁和一定的负载。所以大家尽量采用脚本的方式在业务低峰期进行。（MyISAM引擎需要锁住全表）

<参考>

https://yq.aliyun.com/articles/280417?spm=a2c4e.11153959.0.0.37da147cWHTxoH

https://www.percona.com/doc/percona-toolkit/LATEST/pt-table-checksum.html

https://www.percona.com/doc/percona-toolkit/LATEST/pt-table-sync.html
