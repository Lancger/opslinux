#!/usr/bin/env python
# -*- coding: utf-8 -*-#
# auth:xucl

import sys
import time
from datetime import datetime
import MySQLdb


class DBUtil:
    def __init__(self, user=None, passwd=None, host=None, port=None, db=None):
        self.user = user
        self.passwd = passwd
        self.host = host
        self.port = port
        self.db = db
        self._conn = None
        self._cursor = None

    def __enter__(self):
        self._conn = MySQLdb.connect(host=self.host, port=self.port, user=self.user, passwd=self.passwd, db=self.db)
        self._cursor = self._conn.cursor()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self._conn.close()
        self._conn = None

    def check_table_size(self):
        try:
            sql = "select table_schema,table_name,concat(round((data_length+index_length)/1024/1024,2),'M') FROM \
            information_schema.tables where (DATA_LENGTH+INDEX_LENGTH) > 10*1024*1024*1024  and table_schema not in \
('information_schema','mysql','performance_schema','sys')"
            self._cursor.execute(sql)
            result = self._cursor.fetchall()
            print('检查超过10G大小的表')
            if not result:
                print("结果不存在")
            for row in result:
                print(("schema: %s tablename: %s size: %s") % (row[0], row[1], row[2]))
        except Exception as e:
            raise (e)

    def check_table_index(self):
        try:
            sql = "select t1.name,t2.num from information_schema.innodb_sys_tables t1, (select table_id,count(*) as num from \
information_schema.innodb_sys_indexes group by table_id having count(*) >=6) t2 where t1.table_id =t2.table_id"
            self._cursor.execute(sql)
            result = self._cursor.fetchall()
            print('检查索引超过6个的表')
            if not result:
                print("结果不存在")
            for row in result:
                print()
                print(("schema: %s tablename: %s index_num: %s") % (row[0].split('/')[0], row[0].split('/')[1], row[1]))
        except Exception as e:
            raise (e)

    def check_table_fragment_pct(self):
        try:
            sql = "SELECT TABLE_SCHEMA as `db`, TABLE_NAME as `tbl`,   \
1-(TABLE_ROWS*AVG_ROW_LENGTH)/(DATA_LENGTH + INDEX_LENGTH + DATA_FREE) AS `fragment_pct`   \
FROM information_schema.TABLES WHERE  TABLE_SCHEMA not in ('information_schema','mysql','performance_schema','sys') \
and (1-(TABLE_ROWS*AVG_ROW_LENGTH)/(DATA_LENGTH + INDEX_LENGTH + DATA_FREE)) > 0.5 and (DATA_LENGTH + INDEX_LENGTH + DATA_FREE) > 1024*1024*1024 ;"
            self._cursor.execute(sql)
            result = self._cursor.fetchall()
            print('检查碎片率超过50%的表')
            if not result:
                print("结果不存在")
            for row in result:
                print(("schema: %s tablename: %s fragment_pct: %s") % (row[0], row[1], row[2]))
        except Exception as e:
            raise (e)

    def check_table_rows(self):
        try:
            sql = "select table_schema,table_name,table_rows from \
information_schema.TABLES where table_schema not in ('information_schema','mysql','performance_schema','sys') \
and table_rows > 10000000 order by table_rows desc;"
            self._cursor.execute(sql)
            result = self._cursor.fetchall()
            print('检查行数超过1000万行的表')
            if not result:
                print("结果不存在")
            for row in result:
                print(("schema: %s tablename: %s rows: %s") % (row[0], row[1], row[2]))
        except Exception as e:
            raise (e)

    def check_table_chaset(self):
        try:
            self._cursor.execute("show variables like 'character_set_server';")
            default_charset = str(self._cursor.fetchone()[1])
            default_charset = default_charset + "_general_ci"
            sql = "select table_schema,table_name,table_collation from information_schema.tables where table_schema not \
in ('information_schema','mysql','performance_schema','sys') and table_collation !='" + default_charset + "';"
            result = self._cursor.fetchall()
            print('检查非默认字符集的表')
            if not result:
                print("结果不存在")
            for row in result:
                print(("schema: %s tablename: %s fragment_pct: %s") % (row[0], row[1], row[2]))
        except Exception as e:
            raise (e)

    def check_table_big_columns(self):
        try:
            sql = "select table_schema,table_name,column_name,data_type from information_schema.columns where data_type in \
('blob','clob','text','medium text','long text') and table_schema not in \
('information_schema','performance_schema','mysql','sys')"
            self._cursor.execute(sql)
            result = self._cursor.fetchall()
            print('检查含大字段的表')
            if not result:
                print("结果不存在")
            for row in result:
                print(("schema: %s tablename: %s column_name: %s data_type: %s") % (row[0], row[1], row[2], row[3]))
        except Exception as e:
            raise (e)

    def check_table_long_varchar(self):
        try:
            sql = "select table_schema,table_name,column_name,data_type,CHARACTER_MAXIMUM_LENGTH from information_schema.columns \
where DATA_TYPE='varchar' and CHARACTER_MAXIMUM_LENGTH > 500 and table_schema not in \
('information_schema','performance_schema','mysql','sys');"
            self._cursor.execute(sql)
            result = self._cursor.fetchall()
            print('检查varchar定义长的表')
            if not result:
                print("结果不存在")
            for row in result:
                print(("schema: %s tablename: %s column_name: %s data_type: %s(%s)") % (
                    row[0], row[1], row[2], row[3], row[4]))
        except Exception as e:
            raise (e)

    def check_table_no_index(self):
        try:
            sql = "SELECT t.table_schema,t.table_name FROM information_schema.tables AS t LEFT JOIN \
(SELECT DISTINCT table_schema, table_name FROM information_schema.`KEY_COLUMN_USAGE` ) AS kt ON \
kt.table_schema=t.table_schema AND kt.table_name = t.table_name WHERE t.table_schema NOT IN \
('mysql', 'information_schema', 'performance_schema', 'sys') AND kt.table_name IS NULL;"
            self._cursor.execute(sql)
            result = self._cursor.fetchall()
            print('检查无主键/索引的表')
            if not result:
                print("结果不存在")
            for row in result:
                print(("schema: %s tablename: %s") % (row[0], row[1]))
        except Exception as e:
            raise (e)

    def check_index_redundant(self):
        try:
            sql = "select table_schema,table_name,redundant_index_name,redundant_index_columns  from \
            sys.schema_redundant_indexes group by table_schema,table_name,redundant_index_name,redundant_index_columns;"
            self._cursor.execute(sql)
            result = self._cursor.fetchall()
            print('检查重复索引')
            if not result:
                print("结果不存在")
            for row in result:
                print(("schema: %s tablename: %s redundant_index_name：%s redundant_index_columns:%s ") % (
                    row[0], row[1], row[2], row[3]))
        except Exception as e:
            raise (e)

    def check_index_columns(self):
        try:
            sql = "select s.table_schema,s.table_name,s.index_name,s.column_name from information_schema.STATISTICS s,\
(select table_name,index_name,count(*) from information_schema.STATISTICS where table_schema not in \
('information_schema','performance_schema','mysql','sys') group by table_name,index_name having count(*)>5)t where \
s.table_name=t.table_name and s.index_name=t.index_name;"
            self._cursor.execute(sql)
            result = self._cursor.fetchall()
            print('检查索引列超过5个的索引')
            if not result:
                print("结果不存在")
            for row in result:
                print(("schema: %s tablename: %s index_name：%s column_name:%s ") % (row[0], row[1], row[2], row[3]))
        except Exception as e:
            raise (e)

    def check_index_unused(self):
        try:
            sql = "select * from sys.schema_unused_indexes;"
            self._cursor.execute(sql)
            result = self._cursor.fetchall()
            print('检查无用的索引')
            if not result:
                print("结果不存在")
            for row in result:
                print(("schema: %s tablename: %s indexname：%s") % (row[0], row[1], row[2]))
        except Exception as e:
            raise (e)

    def check_important_variables(self):
        print('检查重要参数')
        variables_list = ['version', 'innodb_buffer_pool_size', 'innodb_flush_log_at_trx_commit',
                          'innodb_log_file_size', 'innodb_log_files_in_group', 'innodb_file_per_table',
                          'innodb_max_dirty_pages_pct', 'sync_binlog', 'max_connections', 'query_cache_type',
                          'table_open_cache', 'table_definition_cache']

        for variable in variables_list:
            try:
                sql = ("show global variables like '%s'" % variable)
                self._cursor.execute(sql)
                result = self._cursor.fetchone()[1]
                print(('%s : %s') % (variable, result))
            except Exception as e:
                raise (e)

    def check_important_status(self):
        print('检查重要状态')
        status_list = ['Uptime', 'Opened_files', 'Opened_table_definitions', 'Opened_tables', 'Max_used_connections',
                       'Threads_created', 'Threads_connected', 'Aborted_connects', 'Aborted_clients',
                       'Table_locks_waited', 'Innodb_buffer_pool_wait_free', 'Innodb_log_waits',
                       'Innodb_row_lock_waits', 'Innodb_row_lock_time_avg', 'Binlog_cache_disk_use', 'Created_tmp_disk_tables']
        for status in status_list:
            try:
                sql = ("show global status like '%s'" % status)
                self._cursor.execute(sql)
                result = self._cursor.fetchone()[1]
                print(('%s : %s') % (status, result))
            except Exception as e:
                raise (e)
        self._cursor.execute("show engine innodb status")
        innodb_status = self._cursor.fetchall()
        innodb_status_format = str(innodb_status).split('\\n')
        for item in innodb_status_format:
            if "Log sequence number" in item:
                logsequencenumber = item.split(' ')[3]
                print(('%s : %s') % ('Log sequence number', logsequencenumber))
            if "Log flushed up to" in item:
                logflushnumber = item.split(' ')[6]
                print(('%s : %s') % ('Log flushed up to', logflushnumber))
            if "Last checkpoint at" in item:
                checkpoint = item.split(' ')[4]
                print(('%s : %s') % ('Last checkpoint at', checkpoint))
            if "History list length" in item:
                historylength = item.split(' ')[3]
                print(('%s : %s') % ('historylength', historylength))


    def check_user_nopass(self):
        try:
            sql = "select user,host from mysql.user where authentication_string='';"
            self._cursor.execute(sql)
            result = self._cursor.fetchall()
            print('检查无密码用户')
            if not result:
                print("结果不存在")
            for row in result:
                print(("user: %s host: %s") % (row[0], row[1]))
        except Exception as e:
            raise (e)

    def check_user_nowhere(self):
        try:
            sql = "select user,host from mysql.user where host='%';"
            self._cursor.execute(sql)
            result = self._cursor.fetchall()
            print('检查%用户')
            if not result:
                print("结果不存在")
            for row in result:
                print(("user: %s host: %s") % (row[0], row[1]))
        except Exception as e:
            raise (e)

    def check_user_privileges(self):
        try:
            sql = "select user,host from mysql.user where user not in ('mysql.session','mysql.sys');"
            self._cursor.execute(sql)
            result = self._cursor.fetchall()
            user_list = []
            for row in result:
                user_list.append("'" + row[0] + "'" + "@" + "'" + row[1] + "'")
            print('检查用户权限')
            for user in user_list:
                sql = "show grants for %s;" % user
                # print(sql)
                self._cursor.execute(sql)
                result = self._cursor.fetchall()
                for row in result:
                    print(row[0])
        except Exception as e:
            raise (e)


if __name__ == '__main__':
    with DBUtil('user', 'password', 'hostip', 3306, 'information_schema') as client:
        client.check_table_size()
        client.check_table_index()
        client.check_table_fragment_pct()
        client.check_table_rows()
        client.check_table_chaset()
        client.check_table_big_columns()
        client.check_table_long_varchar()
        client.check_table_no_index()
        client.check_index_redundant()
        client.check_index_columns()
        client.check_index_unused()
        client.check_important_variables()
        client.check_important_status()
        client.check_user_nopass()
        client.check_user_nowhere()
        client.check_user_privileges()