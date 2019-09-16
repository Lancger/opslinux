#!/bin/bash
usage() { echo "Usage: $0 [-s <zabbix server ip(s)>] [-n <zabbix host name>]" 1>&2; exit 1; }
if [ ! "$#" == "4" ]; then usage; fi
while getopts ":s:n:" o; do
    case "${o}" in
        s)
            server=${OPTARG}
            ;;
        n)
            hostname=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done

echo "[Start to Install Zabbix Agent...]"

#System Detect from Oneinstack
if [ -n "$(grep 'Aliyun Linux release' /etc/issue)" -o -e /etc/redhat-release ]; then
	OS=CentOS
	[ -n "$(grep ' 7\.' /etc/redhat-release 2> /dev/null)" ] && CentOS_RHEL_version=7
	[ -n "$(grep ' 6\.' /etc/redhat-release 2> /dev/null)" -o -n "$(grep 'Aliyun Linux release6 15' /etc/issue)" ] && CentOS_RHEL_version=6
	[ -n "$(grep ' 5\.' /etc/redhat-release 2> /dev/null)" -o -n "$(grep 'Aliyun Linux release5' /etc/issue)" ] && CentOS_RHEL_version=5
elif [ -n "$(grep 'Amazon Linux AMI release' /etc/issue)" -o -e /etc/system-release ]; then
	OS=CentOS
	CentOS_RHEL_version=6
elif [ -n "$(grep 'bian' /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == "Debian" ]; then
	OS=Debian
	[ ! -e "$(which lsb_release)" ] && { apt-get -y update > /dev/null; apt-get -y install lsb-release > /dev/null;}
	Debian_version=$(lsb_release -sr | awk -F. '{print $1}')
elif [ -n "$(grep 'Deepin' /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == "Deepin" ]; then
	OS=Debian
	[ ! -e "$(which lsb_release)" ] && { apt-get -y update > /dev/null; apt-get -y install lsb-release > /dev/null;}
	Debian_version=$(lsb_release -sr | awk -F. '{print $1}')
# kali rolling
elif [ -n "$(grep 'Kali GNU/Linux Rolling' /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == "Kali" ]; then
	OS=Debian
	[ ! -e "$(which lsb_release)" ] && { apt-get -y update > /dev/null; apt-get -y install lsb-release > /dev/null;}
	if [ -n "$(grep 'VERSION="2016.*"' /etc/os-release)" ]; then
		Debian_version=8
	else
		echo "${CFAILURE}Does not support this OS, Please contact the author! ${CEND}"
		kill -9 $$
	fi
elif [ -n "$(grep 'Ubuntu' /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == "Ubuntu" -o -n "$(grep 'Linux Mint' /etc/issue)" ]; then
	OS=Ubuntu
	[ ! -e "$(which lsb_release)" ] && { apt-get -y update > /dev/null; apt-get -y install lsb-release > /dev/null;}
	Ubuntu_version=$(lsb_release -sr | awk -F. '{print $1}')
	[ -n "$(grep 'Linux Mint 18' /etc/issue)" ] && Ubuntu_version=16
elif [ -n "$(grep 'elementary' /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'elementary' ]; then
	OS=Ubuntu
	[ ! -e "$(which lsb_release)" ] && { apt-get -y update > /dev/null; apt-get -y install lsb-release > /dev/null;}
	Ubuntu_version=16
else
	echo "Does not support this OS!!!"
	kill -9 $$
fi

if [ "$(getconf WORD_BIT)" == "32" ] && [ "$(getconf LONG_BIT)" == "64" ]; then
	OS_BIT=64
else
	OS_BIT=32
fi

#Install Zabbix-agent from repo
case $OS in
	CentOS)
		yum install wget -y
		echo "[Disable SELinux for Centos]"
		sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
		case $CentOS_RHEL_version in
			5)
				if [ $OS_BIT == 32 ]; then
					rpm -ivh https://repo.zabbix.com/zabbix/3.4/rhel/5/i386/zabbix-agent-3.4.14-1.el5.i686.rpm
				else
					rpm -ivh https://repo.zabbix.com/zabbix/3.4/rhel/5/x86_64/zabbix-agent-3.4.14-1.el5.x86_64.rpm
				fi
				;;
			6)
				if [ $OS_BIT == 32 ]; then
					rpm -ivh https://repo.zabbix.com/zabbix/3.4/rhel/6/i386/zabbix-agent-3.4.14-1.el6.i686.rpm
				else
					rpm -ivh https://repo.zabbix.com/zabbix/3.4/rhel/6/x86_64/zabbix-agent-3.4.14-1.el6.x86_64.rpm
				fi
				;;
			7)
				rpm -ivh https://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-agent-3.4.14-1.el7.x86_64.rpm
				;;
			*)
				;;
		esac
		echo "[Successfully installed Zabbix-agent in Centos]"
		;;
	Debian)
		apt-get install libcurl3 -y > /dev/null 2>&1
		case $Debian_version in
			7)
				if [ $OS_BIT == 32 ]; then
					wget https://repo.zabbix.com/zabbix/3.4/debian/pool/main/z/zabbix/zabbix-agent_3.4.14-1%2Bwheezy_i386.deb -P /tmp/ > /dev/null 2>&1
				else
					wget https://repo.zabbix.com/zabbix/3.4/debian/pool/main/z/zabbix/zabbix-agent_3.4.14-1%2Bwheezy_amd64.deb -P /tmp/ > /dev/null 2>&1
				fi
				;;
			8)
				if [ $OS_BIT == 32 ]; then
					wget https://repo.zabbix.com/zabbix/3.4/debian/pool/main/z/zabbix/zabbix-agent_3.4.14-1%2Bjessie_i386.deb -P /tmp/ > /dev/null 2>&1
				else
					wget https://repo.zabbix.com/zabbix/3.4/debian/pool/main/z/zabbix/zabbix-agent_3.4.14-1%2Bjessie_amd64.deb -P /tmp/ > /dev/null 2>&1
				fi
				;;
			9)
				if [ $OS_BIT == 32 ]; then
					wget https://repo.zabbix.com/zabbix/3.4/debian/pool/main/z/zabbix/zabbix-agent_3.4.14-1%2Bstretch_i386.deb -P /tmp/ > /dev/null 2>&1
				else
					wget https://repo.zabbix.com/zabbix/3.4/debian/pool/main/z/zabbix/zabbix-agent_3.4.14-1%2Bstretch_amd64.deb -P /tmp/ > /dev/null 2>&1
				fi
				;;
			*)
				;;
		esac
		dpkg -i /tmp/zabbix-agent*.deb
		echo "[Successfully installed Zabbix-agent in Debian]"
		;;
	Ubuntu)
		apt-get install libcurl3 -y > /dev/null 2>&1
		case $Ubuntu_version in
			14)
				if [ $OS_BIT == 32 ]; then
					wget https://repo.zabbix.com/zabbix/3.4/ubuntu/pool/main/z/zabbix/zabbix-agent_3.4.14-1%2Btrusty_i386.deb -P /tmp/ > /dev/null 2>&1
				else
					wget https://repo.zabbix.com/zabbix/3.4/ubuntu/pool/main/z/zabbix/zabbix-agent_3.4.14-1%2Btrusty_amd64.deb -P /tmp/ > /dev/null 2>&1
				fi
				;;
			16)
				if [ $OS_BIT == 32 ]; then
					wget https://repo.zabbix.com/zabbix/3.4/ubuntu/pool/main/z/zabbix/zabbix-agent_3.4.14-1%2Bxenial_i386.deb -P /tmp/ > /dev/null 2>&1
				else
					wget https://repo.zabbix.com/zabbix/3.4/ubuntu/pool/main/z/zabbix/zabbix-agent_3.4.14-1%2Bxenial_amd64.deb -P /tmp/ > /dev/null 2>&1
				fi
				;;
			18)
				if [ $OS_BIT == 32 ]; then
					wget https://repo.zabbix.com/zabbix/3.4/ubuntu/pool/main/z/zabbix/zabbix-agent_3.4.14-1%2Bbionic_i386.deb -P /tmp/ > /dev/null 2>&1
				else
					wget https://repo.zabbix.com/zabbix/3.4/ubuntu/pool/main/z/zabbix/zabbix-agent_3.4.14-1%2Bbionic_amd64.deb -P /tmp/ > /dev/null 2>&1
				fi
				;;
			*)
				;;
		esac
		dpkg -i /tmp/zabbix-agent*.deb
		echo "[Successfully installed Zabbix-agent in Ubuntu]"
		;;
	*)
		echo "Error: Could not detect System!"
		read -n 1 -p "If you ensure you have installed the Zabbix-agent, Press any key to continue"
		;;
esac
echo ''

#Edit the config file
sed -i 's/# EnableRemoteCommands=0/EnableRemoteCommands=1/g' /etc/zabbix/zabbix_agentd.conf
sed -i 's/# LogRemoteCommands=0/LogRemoteCommands=1/g' /etc/zabbix/zabbix_agentd.conf

sed -i "s/Server=127.0.0.1/Server=$server/g" /etc/zabbix/zabbix_agentd.conf
sed -i "s/ServerActive=127.0.0.1/ServerActive=$server/g" /etc/zabbix/zabbix_agentd.conf

sed -i "s/Hostname=Zabbix server/Hostname=$hostname/g" /etc/zabbix/zabbix_agentd.conf
echo ""

#Configure the Iptables
if
	! iptables-save | grep "10050 -j ACCEPT" > /dev/null 2>&1
	then
	iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport 10050 -j ACCEPT
else
	echo "Iptables rule have already been set"
fi

#Use rc.local to start zabbix and load iptables on boot
if
	[ ! -f "/etc/rc.local" ]; then
	ln -s /etc/rc.d/rc.local /etc/rc.local
fi
chmod +x /etc/rc.local

case $OS in
	CentOS)
		service iptables save
		;;
	*)
		iptables-save > /etc/iptables.za.rules
		if
			! cat /etc/rc.local | grep "iptables-restore < /etc/iptables.za.rules" > /dev/null 2>&1
		then
			echo "[Add Zabbix-Agent start on boot]"
			if
				cat /etc/rc.local | grep "exit 0" > /dev/null 2>&1
			then
				sed -i "s/exit 0/iptables-restore < \/etc\/iptables.za.rules\nexit 0/g" /etc/rc.local
			else
				echo "iptables-restore < /etc/iptables.za.rules" >> /etc/rc.local
			fi
		fi
		;;
esac
			

#Enable the Sudo for Zabbix Agent
echo "zabbix	ALL=NOPASSWD: ALL" >> /etc/sudoers
sed -i -r "s/Defaults(.*)requiretty/#Defaults		requiretty/g" /etc/sudoers
grep -q '!visiblepw' /etc/sudoers
if [ $? -eq 0 ] ; then
	sed -i -r "s/(.*)Defaults(.*)\!visiblepw/Defaults		visiblepw/g" /etc/sudoers
else
	echo "Defaults		visiblepw" >> /etc/sudoers
fi
echo "[Setting Finished]"
echo ""

#Start Zabbix-agent on Boot
if
	cat /etc/rc.local | grep "service zabbix-agent start" > /dev/null 2>&1
	then
		echo "Start on boot Already Exists"
	else
	echo "[Add Zabbix-Agent start on Boot]"
	if
		cat /etc/rc.local | grep "exit 0" > /dev/null 2>&1
		then
			sed -i "s/exit 0/service zabbix-agent start\nexit 0/g" /etc/rc.local
		else
			echo "service zabbix-agent start" >> /etc/rc.local
	fi
fi
echo "[Starting the Zabbix-Agent....]"

service zabbix-agent start

if
	ps -A | grep "zabbix_agent" > /dev/null 2>&1
	then
		echo "Zabbix-agent is Running"
	else
		echo "Zabbix-agent is not Run, Please check whether the Zabbix-agent is installed correctly."
fi

