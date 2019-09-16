# 看看MySQL 5.6, 5.7, 8.0的新特性

    对于MySQL的历史，相信很多人早已耳熟能详，这里就不要赘述。下面仅从产品特性的角度梳理其发展过程中的里程碑事件。

    1995年，MySQL 1.0发布，仅供内部使用。

    1996年，MySQL 3.11.1发布，直接跳过了MySQL 2.x版本。

    1999年，MySQL AB公司成立。同年，发布MySQL 3.23，该版本集成了Berkeley DB存储引擎。该引擎由Sleepycat公司开发，支持事务。在集成该引擎的过程中，对源码进行了改造，为后续可插拔式存储引擎架构奠定了基础。

    2000年，ISAM升级为MyISAM存储引擎。同年，MySQL基于GPL协议开放源码。

    2002年，MySQL 4.0发布，集成了后来大名鼎鼎的InnoDB存储引擎。该引擎由Innobase公司开发，支持事务，支持行级锁，适用于OLTP等高并发场景。

    2005年，MySQL 5.0发布，开始支持游标，存储过程，触发器，视图，XA事务等特性。同年，Oracle收购Innobase公司。

    2008年，Sun以10亿美金收购MySQL AB。同年，发布MySQL 5.1，其开始支持定时器（Event scheduler），分区，基于行的复制等特性。

    2009年，Oracle以74亿美金收购Sun公司。

## 2010年，MySQL 5.5发布，其包括如下重要特性及更新。

    InnoDB代替MyISAM成为MySQL默认的存储引擎。
    多核扩展，能更充分地使用多核CPU。
    InnoDB的性能提升，包括支持索引的快速创建，表压缩，I/O子系统的性能提升，PURGE操作从主线程中剥离出来，Buffer Pool可拆分为多个Instances。
    半同步复制。
    引入utf8mb4字符集，可用来存储emoji表情。
    引入metadata locks（元数据锁）。
    分区表的增强，新增两个分区类型：RANGE COLUMNS和LIST COLUMNS。
    MySQL企业版引入线程池。
    可配置IO读写线程的数量（innodb_read_io_threads，innodb_write_io_threads）。在此之前，其数量为1，且不可配置。
    引入innodb_io_capacity选项，用于控制脏页刷新的数量。

## 2013年，MySQL 5.6发布，其包括如下重要特性及更新。

    GTID复制。
    无损复制。
    延迟复制。
    基于库级别的并行复制。
    mysqlbinlog可远程备份binlog。
    对TIME, DATETIME和TIMESTAMP进行了重构，可支持小数秒。DATETIME的空间需求也从之前的8个字节减少到5个字节。
    Online DDL。ALTER操作不再阻塞DML。
    可传输表空间（transportable tablespaces）。
    统计信息的持久化。避免主从之间或数据库重启后，同一个SQL的执行计划有差异。
    全文索引。
    InnoDB Memcached plugin。
    EXPLAIN可用来查看DELETE，INSERT，REPLACE，UPDATE等DML操作的执行计划，在此之前，只支持SELECT操作。
    分区表的增强，包括最大可用分区数增加至8192，支持分区和非分区表之间的数据交换，操作时显式指定分区。
    Redo Log总大小的限制从之前的4G扩展至512G。
    Undo Log可保存在独立表空间中，因其是随机IO，更适合放到SSD中。但仍然不支持空间的自动回收。
    可dump和load Buffer pool的状态，避免数据库重启后需要较长的预热时间。
    InnoDB内部的性能提升，包括拆分kernel mutex，引入独立的刷新线程，可设置多个purge线程。
    优化器性能提升，引入了ICP，MRR，BKA等特性，针对子查询进行了优化。
    可以说，MySQL 5.6是MySQL历史上一个里程碑式的版本，这也是目前生产上应用得最广泛的版本。


## 2015年，MySQL 5.7发布，其包括如下重要特性及更新。

    组复制
    InnoDB Cluster
    多源复制
    增强半同步（AFTER_SYNC）
    基于WRITESET的并行复制。
    在线开启GTID复制。
    在线设置复制过滤规则。
    在线修改Buffer pool的大小。
    在同一长度编码字节内，修改VARCHAR的大小只需修改表的元数据，无需创建临时表。
    可设置NUMA架构的内存分配策略（innodb_numa_interleave）。
    透明页压缩（Transparent Page Compression）。
    UNDO表空间的自动回收。
    查询优化器的重构和增强。
    可查看当前正在执行的SQL的执行计划（EXPLAIN FOR CONNECTION）。
    引入了查询改写插件（Query Rewrite Plugin），可在服务端对查询进行改写。
    EXPLAIN FORMAT=JSON会显示成本信息，这样可直观的比较两种执行计划的优劣。
    引入了虚拟列，类似于Oracle中的函数索引。
    新实例不再默认创建test数据库及匿名用户。
    引入ALTER USER命令，可用来修改用户密码，密码的过期策略，及锁定用户等。
    mysql.user表中存储密码的字段从password修改为authentication_string。
    表空间加密。
    优化了Performance Schema，其内存使用减少。
    Performance Schema引入了众多instrumentation。常用的有Memory usage instrumentation，可用来查看MySQL的内存使用情况，Metadata Locking Instrumentation，可用来查看MDL的持有情况，Stage Progress instrumentation，可用来查看Online DDL的进度。
    同一触发事件（INSERT，DELETE，UPDATE），同一触发时间（BEFORE，AFTER），允许创建多个触发器。在此之前，只允许创建一个触发器。
    InnoDB原生支持分区表，在此之前，是通过ha_partition接口来实现的。
    分区表支持可传输表空间特性。
    集成了SYS数据库，简化了MySQL的管理及异常问题的定位。
    原生支持JSON类型，并引入了众多JSON函数。
    引入了新的逻辑备份工具-mysqlpump，支持表级别的多线程备份。
    引入了新的客户端工具-mysqlsh，其支持三种语言：JavaScript, Python and SQL。两种API：X DevAPI，AdminAPI，其中，前者可将MySQL作为文档型数据库进行操作，后者用于管理InnoDB Cluster。
    mysql_install_db被mysqld --initialize代替，用来进行实例的初始化。
    原生支持systemd。
    引入了super_read_only选项。
    可设置SELECT操作的超时时长（max_execution_time）。
    可通过SHUTDOWN命令关闭MySQL实例。
    引入了innodb_deadlock_detect选项，在高并发场景下，可使用该选项来关闭死锁检测。
    引入了Optimizer Hints，可在语句级别控制优化器的行为，如是否开启ICP，MRR等，在此之前，只有Index Hints。
    GIS的增强，包括使用Boost.Geometry替代之前的GIS算法，InnoDB开始支持空间索引。
 

## 2018年，MySQL 8.0发布，其包括如下重要特性及更新。

    引入了原生的，基于InnoDB的数据字典。数据字典表位于mysql库中，对用户不可见，同mysql库的其它系统表一样，保存在数据目录下的mysql.ibd文件中。不再置于mysql目录下。
    Atomic DDL。
    重构了INFORMATION_SCHEMA，其中，部分表已重构为基于数据字典的视图，在此之前，其为临时表。
    PERFORMANCE_SCHEMA查询性能提升，其已内置多个索引。
    不可见索引（Invisible index）。
    降序索引。
    直方图。
    公用表表达式（Common table expressions）。
    窗口函数（Window functions）。
    角色（Role）。
    资源组（Resource Groups），可用来控制线程的优先级及其能使用的资源，目前，能被管理的资源只有CPU。
    引入了innodb_dedicated_server选项，可基于服务器的内存来动态设置innodb_buffer_pool_size，innodb_log_file_size和innodb_flush_method。
    快速加列（ALGORITHM=INSTANT）。
    JSON字段的部分更新（JSON Partial Updates）。
    自增主键的持久化。
    可持久化全局变量（SET PERSIST）。
    默认字符集由latin1修改为utf8mb4。
    默认开启UNDO表空间，且支持在线调整数量（innodb_undo_tablespaces）。在MySQL 5.7中，默认不开启，若要开启，只能初始化时设置。
    备份锁。
    Redo Log的优化，包括允许多个用户线程并发写入log buffer，可动态修改innodb_log_buffer_size的大小。
    默认的认证插件由mysql_native_password更改为caching_sha2_password。
    默认的内存临时表由MEMORY引擎更改为TempTable引擎，相比于前者，后者支持以变长方式存储VARCHAR，VARBINARY等变长字段。从MySQL 8.0.13开始，TempTable引擎支持BLOB字段。
    Grant不再隐式创建用户。
    SELECT ... FOR SHARE和SELECT ... FOR UPDATE语句中引入NOWAIT和SKIP LOCKED选项，解决电商场景热点行问题。
    正则表达式的增强，新增了4个相关函数，REGEXP_INSTR()，REGEXP_LIKE()，REGEXP_REPLACE()，REGEXP_SUBSTR()。
    查询优化器在制定执行计划时，会考虑数据是否在Buffer Pool中。而在此之前，是假设数据都在磁盘中。
    ha_partition接口从代码层移除，如果要使用分区表，只能使用InnoDB存储引擎。
    引入了更多细粒度的权限来替代SUPER权限，现在授予SUPER权限会提示warning。
    GROUP BY语句不再隐式排序。
    MySQL 5.7引入的表空间加密特性可对Redo Log和Undo Log进行加密。
    information_schema中的innodb_locks和innodb_lock_waits表被移除，取而代之的是performance_schema中的data_locks和data_lock_waits表。
    引入performance_schema.variables_info表，记录了参数的来源及修改情况。
    增加了对于客户端报错信息的统计（performance_schema.events_errors_summary_xxx）。
    可统计查询的响应时间分布（call sys.ps_statement_avg_latency_histogram()）。
    支持直接修改列名（ALTER TABLE ... RENAME COLUMN old_name TO new_name）。
    用户密码可设置重试策略（Reuse Policy）。
    移除PASSWORD()函数。这就意味着无法通过“SET PASSWORD ... = PASSWORD('auth_string') ”命令修改用户密码。
    代码层移除Query Cache模块，故Query Cache相关的变量和操作均不再支持。
    BLOB, TEXT, GEOMETRY和JSON字段允许设置默认值。
    可通过RESTART命令重启MySQL实例。
 
## 需要注意的是，上面提到的发布，一般指的是GA版本。

    最后，看看下面这个表格，表中给出了最近几个大版本的发布时间，及截止到本书出版，其最新的小版本及其发布时间。
    
![mysql发展历史](https://github.com/Lancger/opslinux/blob/master/images/mysql发展.png)


    从表中的数据来看，

    1. 大概每3年会发布一个大的版本。

    2. 产品的支持周期一般是8年。

    3. 以为MySQL 5.5是老古董了，但官方仍然在不断更新。
    
    
参考文档： 

https://en.wikipedia.org/wiki/MySQL#Release_history

https://www.cnblogs.com/ivictor/p/9807284.html
