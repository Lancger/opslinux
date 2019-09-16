## 一、批量ping脚本（单进程方式）

脚本内容
```
#!/usr/bin/env python
# -*- coding: utf-8 -*-  
import subprocess
import time

# import sys
# reload(sys)
# sys.setdefaultencoding('utf-8')

# 记录开始执行的时间
start_time = time.time()

# 定义用来 ping 的254 个 ip
ip_list = ['192.168.56.'+str(i) for i in range(1,255)]  

for ip in ip_list:
    res = subprocess.call('ping -c 2 -w 5 %s' % ip, stdout=subprocess.PIPE, shell=True)
    print (ip,True if res == 0 else False)

print('执行所用时间：%s' % (time.time() - start_time))
```
执行结果
```
(demo2) [root@localhost ~]# python 1.py
('192.168.119.1', True)
('192.168.119.2', False)
('192.168.119.3', False)
('192.168.119.4', False)
('192.168.119.5', False)
......
执行所用时间：100s
```

## 二、改造成多线程
```
#!/usr/bin/env python
# -*- coding: utf-8 -*-
import threading
import subprocess
import time
from Queue import Queue

# import sys
# reload(sys)
# sys.setdefaultencoding('utf-8')

# 定义工作线程
WORD_THREAD = 50

# 将需要 ping 的 ip 加入队列
IP_QUEUE = Queue()
for i in range(1,255):
    IP_QUEUE.put('192.168.56.'+str(i))

# 定义一个执行 ping 的函数
def ping_ip():
    while not IP_QUEUE.empty():
        ip = IP_QUEUE.get()
        res = subprocess.call('ping -c 2 -w 5 %s' % ip,stdout=subprocess.PIPE, shell=True)  # linux 系统将 '-n' 替换成 '-c'
        # 打印运行结果
        print(ip,True if res == 0 else False)

if __name__ == '__main__':
    threads = []
    start_time = time.time()
    for i in range(WORD_THREAD):
        thread = threading.Thread(target=ping_ip)
        thread.start()
        threads.append(thread)

    for thread in threads:
        thread.join()

    print('程序运行耗时：%s' % (time.time() - start_time))
```
执行结果
```
('192.168.56.87', False)
('192.168.56.76', False)
('192.168.56.94', False)
('192.168.56.66', False)
('192.168.56.73', False)
('192.168.56.88', False)
('192.168.56.83', False)
('192.168.56.75', False)
```

参考文档：

https://blog.51cto.com/maoxian/2119898

https://stackoverflow.com/questions/30657858/file-gets-created-but-subprocess-call-says-no-such-file-or-directory
