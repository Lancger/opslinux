#!/bin/bash
# description: control.sh start tomcat-admin-web

APP_NAME=$2
CATALINA_HOME=/data0/opt/$APP_NAME
STARTUP=$CATALINA_HOME/bin/startup.sh
SHUTDOWN=$CATALINA_HOME/bin/shutdown.sh
LOG_FILE=/data0/opt/$APP_NAME/logs/run.log
START_TIME=`date "+%Y-%m-%d %H:%M:%S"`

#服务探活检测
function isstart(){
    pid=`ps -ef|grep -v "grep" |grep "java" |grep $APP_NAME |wc -l`
    if [ $pid = 1 ];then
        # echo "$START_TIME $APP_NAME 服务正常！！！"|tee -a $LOG_FILE
        return 1
    else
        # echo "$START_TIME $APP_NAME 服务异常！！！"|tee -a $LOG_FILE
        return 0
    fi
}

#服务启动
function startup(){
    # echo "$START_TIME $APP_NAME 服务状态"
    isstart
    s=$?
    if [ $s -eq 1 ];then
        pidlist=`ps -ef|grep -v "grep" |grep "java" |grep $APP_NAME |awk '{print $2}'`
        echo "$START_TIME $APP_NAME 服务已经启动,程序运行PID为: $pidlist,不需要再次启动"
    else
        echo "$START_TIME $APP_NAME 服务没有运行,1s后启动程序"
        sleep 1 
        $STARTUP >/dev/null 2>&1
        pidlist=`ps -ef|grep -v "grep" |grep "java" |grep $APP_NAME |awk '{print $2}'`
        echo "$START_TIME $APP_NAME 服务已经运行成功,程序运行PID为: $pidlist"
    fi
}

#服务停止
function shutdown(){
    # echo "$START_TIME $APP_NAME 服务状态"
    isstart
    s=$?
    if [ $s -eq 0 ];then
        echo "$START_TIME $APP_NAME 服务已经关闭,不需要再次关闭"
    else 
        echo "$START_TIME $APP_NAME 服务已经在运行,1s后关闭程序"
        sleep 1
        $SHUTDOWN >/dev/null 2>&1
        pidlist=`ps -ef|grep -v "grep" |grep "java" |grep $APP_NAME |awk '{print $2}'`
        kill -9 $pidlist >/dev/null 2>&1
        pidlist=`ps -ef|grep -v "grep" |grep "java" |grep $APP_NAME |awk '{print $2}'`
        if [ -z "$pidlist" ]
        then
            echo "$START_TIME $APP_NAME 服务已经停止成功！！！"
        else
            echo "$START_TIME $APP_NAME 服务停止失败！！！"
        fi
    fi
}

#服务状态
function status(){
    isstart
    s=$?
    if [ $s -eq 1 ];then
        pidlist=`ps -ef|grep -v "grep" |grep "java" |grep $APP_NAME |awk '{print $2}'`
        echo "$START_TIME $APP_NAME 服务正常运行,程序运行PID为: $pidlist"
    else
        echo "$START_TIME $APP_NAME 服务已经关闭！！！"
    fi
}

#服务重启
function restart(){
    shutdown
    startup
}

case $1 in
    start)
        startup
        ;;
    stop)
        shutdown
        ;;
    restart)
        restart
        ;;
    status)
        status
        ;;
    *)
        echo 'please use : control.sh {start | stop | restart |status} tomcat-admin-web'
    ;;
esac
exit 0
