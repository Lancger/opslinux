#取30天之前的时间戳
date -d $(date -d "-30 day" +%Y%m%d) +%s

------------------------------
MySQL操作命令: 
use galaxy_mc_data;
DELETE FROM t_event_log_07 WHERE created_at < 1560268800;
optimize table t_event_log_07;

DELETE FROM t_event_log_05 WHERE created_at < 1560268800;
optimize table t_event_log_05;

DELETE FROM t_event_log_06 WHERE created_at < 1560268800;
optimize table t_event_log_06;

DELETE FROM t_event_log_03 WHERE created_at < 1560268800;
optimize table t_event_log_03;

DELETE FROM t_event_log_04 WHERE created_at < 1560268800;
optimize table t_event_log_04;


https://www.cnblogs.com/Camiluo/p/9996650.html
