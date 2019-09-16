#!/bin/sh

cd /

logfile="proxy.log"

echo "#######################################" >> $logfile

wget_proxy ()
{
	if [ -f "ssh_proxy.zip" ]; then
		printf "\033[32m$(date +'%Y-%m-%d %H:%M:%S') %-30s 代理包已经存在 \n\033[0m"|tee -a $logfile
    else
        wget http://*****:8090/ssh_proxy.zip
        printf "\033[32m$(date +'%Y-%m-%d %H:%M:%S') %-30s 开始下载代理包 \n\033[0m"|tee -a $logfile
    fi
}

unzip_proxy ()
{
	if [ ! -d "/ssh_proxy" ]; then
		printf "\033[32m$(date +'%Y-%m-%d %H:%M:%S') %-30s 代理包目录不存在，现在开始解压代理目录包 \n\033[0m"|tee -a $logfile
        unzip ssh_proxy.zip
    else
    	printf "\033[32m$(date +'%Y-%m-%d %H:%M:%S') %-30s 代理包目录解压包已经存在 \n\033[0m"|tee -a $logfile
    fi
}

check_proxy ()
{
	res=`ps -ef|grep -v grep|grep ssh|awk '{print $6}'|awk -F":" '{print $1}'`
	echo "$res" |while read i
	do
		printf "\033[31m$(date +'%Y-%m-%d %H:%M:%S') %-30s $i 端口已被占用 \n\033[0m"|tee -a $logfile
	done

	result=$(echo $res | grep $1)
    if [[ "$result" != "" ]]
    then
		printf "\033[31m$(date +'%Y-%m-%d %H:%M:%S') %-30s $1 端口已被占用 \n\033[0m"|tee -a $logfile
		exit 2
    else
		printf "\033[32m$(date +'%Y-%m-%d %H:%M:%S') %-30s $1 端口未被占用 \n\033[0m"|tee -a $logfile
    fi	
}

start_proxy ()
{
    printf "\033[32m$(date +'%Y-%m-%d %H:%M:%S') %-30s $1 端口代理服务启动中...... \n\033[0m"|tee -a $logfile
	sh /ssh_proxy/bin/ssh_proxy.sh -U root  -P test  -i  0.0.0.0  -p $1 >/dev/null 2>&1
    
    sleep 5
	res=`ps -ef|grep -v grep|grep ssh|awk '{print $6}'|awk -F":" '{print $1}'`

	result=$(echo $res | grep $1)

	count=0

    while [ "$result" == '' ];do
        if [ "$count" -lt 3 ]; then
        	sh /ssh_proxy/bin/ssh_proxy.sh -U root  -P Tempzgb@  -i  120.79.210.87  -p $1 >/dev/null 2>&1
        	sleep 6
            res=`ps -ef|grep -v grep|grep ssh|awk '{print $6}'|awk -F":" '{print $1}'`
            result=$(echo $res | grep $1)
            if [[ "$result" = "" ]]
            then
            	printf "\033[31m$(date +'%Y-%m-%d %H:%M:%S') %-30s $1 重试 $count 次 \n\033[0m"|tee -a $logfile
                printf "\033[31m$(date +'%Y-%m-%d %H:%M:%S') %-30s $1 端口代理服务启动失败 \n\033[0m"|tee -a $logfile
            else
            	echo $result
                break
            fi
        else
            break
        fi
    done

    if [[ "$result" != "" ]]
    then
		printf "\033[32m$(date +'%Y-%m-%d %H:%M:%S') %-30s $1 端口代理服务成功启动 \n\033[0m"|tee -a $logfile
    else
		printf "\033[31m$(date +'%Y-%m-%d %H:%M:%S') %-30s $1 端口代理服务成功失败 \n\033[0m"|tee -a $logfile
    fi	

}

main () 
{
	if [ $# != 2 ] ; then
		printf "\033[32mUSAGE: $0  机器SN号      代理端口 \n\033[0m" |tee -a $logfile
		printf "\033[32mUSAGE: $0  OCPZ121115201   10005   \n\033[0m"|tee -a $logfile
        exit 1;
    fi
    port=$2
    printf "\033[32m$(date +'%Y-%m-%d %H:%M:%S') %-30s 当前工作目录为: `pwd` \n\033[0m"|tee -a $logfile
    wget_proxy
    unzip_proxy
    check_proxy $port
    start_proxy $port
}
main $1 $2

