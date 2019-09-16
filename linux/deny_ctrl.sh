#!/bin/bash
###################################################################
#  Deny Real IP for Nginx;  Author: Jager <ge@zhangge.net>        #
# For more information please visit https://zhangge.net/5096.html #
#-----------------------------------------------------------------#
#  Copyright ©2016 zhangge.net. All rights reserved.              #
###################################################################

NGINX_BIN=/usr/local/nginx/sbin/nginx
DENY_CONF=/usr/local/nginx/conf/deny_ip.conf

COLOR_RED=$(    echo -e "\e[31;49m" )
COLOR_GREEN=$(  echo -e "\e[32;49m" )
COLOR_RESET=$(  echo -e "\e[0m"     )

rep_info() { echo;echo -e "${COLOR_GREEN}$*${COLOR_RESET}";echo; }
rep_error(){ echo;echo -e "${COLOR_RED}$*${COLOR_RESET}";echo;exit 1; }

show_help()
{
printf "
###################################################################
#  Deny Real IP for Nginx;  Author: Jager <ge@zhangge.net>        #
# For more information please visit https://zhangge.net/5096.html #
#-----------------------------------------------------------------#
#  Copyright ©2016 zhangge.net. All rights reserved.              #
###################################################################

Usage: $0 [OPTIONS]

OPTIONS:
-h | --help   : Show help of this script
-a | --add    : Add a deny ip to nginx, for example: ./$0 -a 192.168.1.1
-c | --create : Create deny config file($DENY_CONF) for Nginx
-d | --del    : Delete a ip from deny list, for example: ./$0 -d 192.168.1.1
-s | --show   : Show current deny list

"
}

reload_nginx()
{
    $NGINX_BIN -t >/dev/null 2>&1 && \
    $NGINX_BIN -s reload && \
    return 0
}

show_list()
{
   awk -F '["){|]' '/if/ {for(i=2;i<=NF;i++) if ($i!="") printf $i"\n"}' $DENY_CONF 
}

pre_check()
{
    test -f $NGINX_BIN || rep_error "$NGINX_BIN not found,Plz check and edit."
    test -f $DENY_CONF || rep_error "$DENY_CONF not found,Plz check and edit." 
    MATCH_COUNT=$(show_list | grep -w $1 | wc -l)
    return $MATCH_COUNT
}

create_rule()
{
test -f $DENY_CONF && \
rep_error "$DENY_CONF already exist!."
cat >$DENY_CONF<<EOF
if (\$clientRealIp ~* "8.8.8.8") {
    #add_header Content-Type text/plain;
    #echo "son of a bitch,you mother fucker,go fuck yourself!"; 
    return 403;
    break;
}
EOF
test -f $DENY_CONF && \
rep_info "$DENY_CONF create success!" && \
cat $DENY_CONF && \
exit 0

rep_error "$DENY_CONF create failed!" && \
exit 1

}

add_ip()
{
    pre_check $1
    if [[ $? -eq 0 ]];then
        sed -i "s/\")/|$1&/g" $DENY_CONF && \
        reload_nginx && \
        rep_info "add $1 to deny_list success." || \
        rep_error "add $1 to deny_list failed."
    else
        rep_error "$1 has been in deny list!"
        exit
    fi
}

del_ip()
{
    pre_check $1
    if [[ $? -ne 0 ]];then
        sed -ie "s/\(|$1\|$1|\)//g" $DENY_CONF && \
        reload_nginx && \
        rep_info "del $1 from deny_list success." || \
        rep_error "del $1 from deny_list failed."
    else
        rep_error "$1 not found in deny list!"
        exit
    fi
}

case $1 in
    "-s"|"--show" )
        show_list
        exit
        ;;
    "-h"|"--help" )
        show_help
        exit
        ;;
    "-c"|"--create" )
        create_rule
    ;;
esac

while [ $2 ];do
    case $1 in
        "-a"|"--add" )
            add_ip $2;
            ;;
        "-d"|"--del" )
            del_ip $2
            ;;
        * )
            show_help
            ;; 
    esac
    exit
done
show_help
