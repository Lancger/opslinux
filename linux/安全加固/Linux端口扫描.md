portScanner.py
```
# -*- coding = 'utf-8' -*-

import time
import threading
import socket
import platform

from etc import portlist

class PortScanner:
    """
    端口扫描的类
    """
    #默认扫描的是top1000
    _port_list_top_1000 = portlist.port_list_top_1000
    _port_list_top_100 = portlist.port_list_top_100
    _port_list_top_50 = portlist.port_list_top_50
    
    #默认的线程控制数
    thread_limit = 1000

    #默认等待时间限制
    delay_time = 10

    def __init__(self, target_ports = None):
        """
        构造函数，对target_ports参数的设置
        :param target_port: 默认是None
        """
        if target_ports is None:
            self.target_ports = self._port_list_top_1000
        elif type(target_ports) == list:
            self.target_ports = target_ports
        elif type(target_ports) == int:
            self.target_ports = self.check_default_list(target_ports)

    def check_default_list(self, target_port_rank):
        """
        检查端口的范围,端口的范围必须是 top 50, 100, 1000
        :param : target_port_rank: 指定的 top
        """
        if target_port_rank != 50 and target_port_rank != 100 and target_port_rank != 1000:
            print('Invalid port rank %s. should be 50, 100 or 1000' % target_port_rank)
            exit(0)
        
        if target_port_rank == 50:
            return self._port_list_top_50
        elif target_port_rank == 100:
            return self._port_list_top_100
        elif target_port_rank == 1000:
            return  self._port_list_top_1000
    
    def scan(self, host_name, message=''):
        """
        检查输入的hostname 是否正确
        :param host_name: 输入的主机名
               message: TCP连接时发送的消息，默认为空
        """
        host_name = str(host_name)
        if 'http://' in host_name or 'https://' in host_name:
            host_name = host_name[host_name.find('://')+3:]
        
        print('*'*60 + '\n')
        print('start scanning website: {}'.format(host_name))
        
        #获取IP地址
        try:
            server_ip = socket.gethostbyname(host_name)
            print('server IP is : {}'.format(server_ip))
        except socket.error:
            print('hostname {} unknown'.format(host_name))
            return {}
        
        start_time = time.time()
        output = self.scan_port(server_ip, self.delay_time, message.encode('utf-8'))
        stop_time = time.time()

        print('host {} scanned in  {} seconds'.format(host_name, stop_time - start_time))
        print('finished scan!\n')

        return output
            
    def set_thread_limit(self, limit):
        """
        设置最大的扫描线程数
        """
        limit = int(limit)
        if limit <=0 or limit >5000:
            print(
                'Warning: Invalid thread number limit {}!'
                'Please make sure the thread limit is within the range of (1, 50,000)!'.format(limit)
            )
        else:
            self.thread_limit = limit
        
    def set_delay(self, delay):
        """
        设置结束等待连接的秒数
        """
        delay_time = int(delay)
        if delay_time <= 0 or delay_time > 100:
            print(
                'Warning: Invalid delay value {} seconds!'
                'Please make sure the input delay is within the range of (1, 100)'.format(delay)
            )
        else:
            self.delay_time = delay
        print ('Current timeout delay is {} seconds.'.format(self.delay_time))
    
    def show_thread_limit(self):
        """
        返回当前线程数
        """
        print('current thread number is {} '.format(self.thread_limit))
        return self.thread_limit
    
    def show_target_ports(self):
        """
        返回当前端口列表
        """
        print('Current port list is:')
        print(self.target_ports)
        return self.target_ports
    
    def show_delay_time(self):
        """
        返回已设置等待连接的秒数
        """
        print ('Current timeout delay is {} seconds.'.format(self.delay_time))
        return self.delay_time

    def show_top_ports(self, k):
        """
        返回top50,100,1000 常用的端口
        """
        port = int(k)
        port_list = self.check_default_list(port)
        print('Top {} commonly used ports:'.format(port))
        print(port_list)
        return port_list

    def scan_port_helper(self, ip, delay_time, output, message):
        """
        开启多线程扫描
        """
        port_index = 0
        
        while port_index < len(self.target_ports):
            while threading.activeCount() < self.thread_limit and port_index < len(self.target_ports):
                thread = threading.Thread(target=self.TCP_connect, args=(ip, self.target_ports[port_index], delay_time, output, message))
                thread.start()
                port_index += 1
            time.sleep(0.01)
    
    def scan_port(self, ip, delay_time, message):
        """
        控制scan_port_helper函数
        """
        output = {}

        thread = threading.Thread(target=self.scan_port_helper, args=(ip, delay_time, output,message))
        thread.start()

        #等待所有端口扫描完
        while len(output) < len(self.target_ports):
            time.sleep(0.01)
            continue
        
        #输出开放的端口
        for port in self.target_ports:
            if output[port] == 'OPEN':
                print('{} : {}\n'.format(port, output[port]))
        
        return output
    
    def TCP_connect(self, ip, port_number, delay_time, output, message):
        """
        使用TCP握手对给定IP地址上的端口执行状态检查
        """
        #初始化socket在不同的操作系统
        curr_os = platform.system()
        if curr_os == 'Windows':
            TCP_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            TCP_sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            TCP_sock.settimeout(delay_time)
        else:
            TCP_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            TCP_sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR,1)
            TCP_sock.settimeout(delay_time)

        
        try:
            result = TCP_sock.connect_ex((ip, int(port_number)))
            if message != '':
                TCP_sock.sendall(message)
            
            #如果成功返回0
            if result == 0:
                output[port_number] = 'OPEN'
            else:
                output[port_number] = 'CLOSE'
            
            TCP_sock.close()
        
        except socket.error as e:
            #如果失败，意味着端口可能关闭
            output[port_number] = 'CLOSE'
```

main.py
```
import argparse
import portScanner as ps

def main():
    """
    主函数
    """
    parser = argparse.ArgumentParser(description='********** Port Scanner v1.0 **********')
    parser.add_argument('-d', metavar='--domain', dest='hostname', help=' please make sure the input host name is in\
                                                                            the form of "something.com" , "http://something.com! " or ip. ')
    parser.add_argument('-p', metavar='--port', dest='port', help='If target_ports is a list, this list of ports will be used as\
                                                                   the port list to be scanned. If the target_ports is a int, it\
                                                                   should be 50, 100 or 1000, indicating'
                                                                   )
    parser.add_argument('-t', metavar='--thread', dest='thread', help='set the maximum number of thread for port scanning.\
                                                                       default to 1000.'
                                                                     )
    parser.add_argument('-w', metavar='--wait', dest='time', help='Set the time out delay for port scanning in seconds\
                                                                        the time in seconds that a TCP socket waits until \
                                                                        timeout, default to 10s.'
                                                                        )
    parser.add_argument('-s', metavar='show', dest='top', help='show the top50, 100 or 1000 ports list')
    args = parser.parse_args()
    message = 'hello'
    if args.top:
        scanner = ps.PortScanner()
        scanner.show_top_ports(args.top)
    if args.hostname == None:
        print('please input the website that you want to scan or input -h to show this help message and exit')
        exit(0)
    else:
        if args.port:
            scanner = ps.PortScanner(int(args.port))
        else:
            scanner = ps.PortScanner()
        if args.thread:
            scanner.set_thread_limit(int(args.thread))
        if args.time:
            scanner.set_delay(int(args.time))
        scanner.show_thread_limit()
        scanner.show_delay_time()
        output = scanner.scan(args.hostname, message)

if __name__ == '__main__':
    main()
```
参考资料：

https://github.com/luckman666/PortScan 
