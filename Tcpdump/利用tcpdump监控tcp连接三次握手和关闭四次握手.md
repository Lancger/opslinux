## 利用tcpdump监控tcp连接三次握手和关闭四次握手


学习网络编程最主要的是能理解底层编程细节，一开始看《UNIX网络编程卷1：套接字联网API》的时候搞不懂什么seq、ack到底是什么东西，最近了解了tcpdump的一些用法后感觉两者结合起来还是比较容易理握手过程的。以下就通过tcpdump工具来监控相关内容，并和书本上的流程进行对比介绍，希望对入门的童靴有些帮助吧

第一次

第一次握手：建立连接时，客户端发送syn包（syn=j）到服务器，并进入SYN_SENT状态，等待服务器确认；SYN：同步序列编号（Synchronize Sequence Numbers）。

第二次

第二次握手：服务器收到syn包，必须确认客户的SYN（ack=j+1），同时自己也发送一个SYN包（syn=k），即SYN+ACK包，此时服务器进入SYN_RECV状态；

第三次

第三次握手：客户端收到服务器的SYN+ACK包，向服务器发送确认包ACK(ack=k+1），此包发送完毕，客户端和服务器进入ESTABLISHED状态，完成三次握手。

## 一、服务端代码如下：
```
#include <sys/socket.h> //socket listen bind                                     
#include <arpa/inet.h> // sockaddr head                                                                                                                                                                   
#include <string.h>  //memset and strlen head                                       
#include <sys/socket.h> //socket listen bind                                        
#include <iostream>                                                                 
#include <time.h>                                                                   
#include <stdio.h>                                                                  
                                                                                    
#define MAXLINE 4096                                                                
#define LISTENQ 1024                                                                
                                                                                    
using namespace std;                                                                
                                                                                    
int main(int argc, char ** argv)                                                    
{                                                                                   
    int listenfd, connfd;                                                           
    socklen_t len;                                                                  
    struct sockaddr_in servaddr, cliaddr;                                           
    char buff[MAXLINE];                                                             
    time_t ticks;                                                                   
    listenfd = socket(AF_INET, SOCK_STREAM, 0);                                     
    memset(&servaddr, 0, sizeof(servaddr));                                         
    servaddr.sin_family = AF_INET;                                                  
    servaddr.sin_addr.s_addr = htonl(INADDR_ANY);                                   
    servaddr.sin_port = htons(10000);                                               
                                                                                    
    bind(listenfd, (struct sockaddr *)&servaddr, sizeof(servaddr));                 
    int ret = listen(listenfd,LISTENQ);                                             
    cout << "go to listen" <<ret<< endl;                                            
    for(; ;)                                                                        
    {                                                                               
        len=sizeof(cliaddr);                                                        
        connfd = accept(listenfd, (struct sockaddr *)&cliaddr, &len);               
        cout << "connfd = " << connfd << inet_ntop(AF_INET, &cliaddr.sin_addr, buff, sizeof(buff)) << endl;
        sleep(20);                                                                  
        ticks = time(NULL);                                                         
        snprintf(buff, sizeof(buff), "%.24s\r\n", ctime(&ticks));                   
        write(connfd, buff, strlen(buff));                                          
        cout << "write date ok" << endl;                                            
        sleep(20);                                                                  
        close(connfd);                                                              
    } 
    return 0;                                                                    
}  
```

## 二、客户端代码如下：
 ```
 #include <string.h>                                                                 
#include <netinet/in.h>                                                             
#include <sys/socket.h>                                                             
#include <arpa/inet.h>                                                              
#include <iostream>                                                                 
#include <stdio.h>                                                                  
#include <errno.h>                                                               
                                                                                 
using namespace std;                                                             
                                                                                 
#define MAXLINE     4096    /* max text line length */                           
int main(int argc, char ** argv)                                                 
{                                                                                
    int sockfd, n;                                                               
    char recvline[MAXLINE+1];                                                    
    struct sockaddr_in serveraddr;                                               
    if(argc != 2)                                                                
    {                                                                            
        cout << "para error " << endl;                                           
        return 0;                                                                
    }                                                                            
    if((sockfd=socket(AF_INET, SOCK_STREAM, 0))<0)                               
    {                                                                            
        cout << "socket error" << endl;                                          
        return 0;                                                                
    }                                                                            
    memset(&serveraddr,0, sizeof(serveraddr));                                   
    serveraddr.sin_family = AF_INET;                                             
    serveraddr.sin_port = htons(10000);                                          
    if(inet_pton(AF_INET, argv[1], &serveraddr.sin_addr)<=0)                     
    {                                                                            
        cout << "inet_pton error for " << argv[1] << endl;                       
        return 0;                                                                
    }                                                                            
    int tmp = connect(sockfd, (struct sockaddr *)&serveraddr, sizeof(serveraddr));
    if(tmp <0)                                                                                                                                                                                            
    {                                                                               
        cout << "connect error" << tmp << endl;                                     
        cout << "error info " << errno << endl;                                     
        return 0;                                                                   
    } 
    while((n=read(sockfd, recvline, MAXLINE)) > 0)                               
    {                                                                            
        recvline[n] = 0;                                                         
        if(fputs(recvline, stdout) == EOF)                                       
        {                                                                        
            cout << "fputs error" << endl;                                       
        }                                                                        
    }                                                                            
    close(sockfd);                                                               
    if(n<0)                                                                      
    {                                                                            
        cout << "read error" << endl;                                            
    }                                                                            
    return 1;                                                                    
} 
 ```
 
## 三、原理剖析

 先在192.168.11.220上运行服务端程序，然后在192.168.11.223上运行客户端程序。同时在两个服务器上以root用户执行tcpdump工具，监控10000端口

tcpdump命令如下：
```
tcpdump 'port 10000' -i eth0 -S
```
建立连接时服务端220的监控内容如下：
```sh
14:52:19.772673 IP 192.168.11.223.55081 > npsc-220.ndmp: Flags [S], seq 1925249825, win 14600, options [mss 1460,sackOK,TS val 11741993 ecr 0,nop,wscale 6], length 0 
14:52:19.772695 IP npsc-220.ndmp > 192.168.11.223.55081: Flags [S.], seq 821610649, ack 1925249826, win 14480, options [mss 1460,sackOK,TS val 20292985 ecr 11741993,nop,wscale 7], length 0 
14:52:19.773256 IP 192.168.11.223.55081 > npsc-220.ndmp: Flags [.], ack 821610650, win 229, options [nop,nop,TS val 11741994 ecr 20292985], length 0

```
 下面结合上图和下面三次握手示意图，解释握手细节： 
 
第一行显示客户端192.168.11.223先发送一个seq,1925249825给服务端，对应下面三次握手示意图中的SYN J


第二行显示服务端192.168.11.220（npsc-220）确认第一行的请求:seq 1925249825, ack的值为第一行的seq值+1，即(ack 1925249826），同时发送一个请求序列号821610649。对应下图三次握手中的（SYN K, ACK J+1）


第三行显示客户端192.168.11.223确认服务端的请求序号（第二行中的seq 821610649），对应下图tcp三路握手中的 （ACK K+1）

  ![TCP三次握手原理](https://github.com/Lancger/opslinux/blob/master/images/tcpdump1.png)

下图显示了传递一次数据的通信过程

  ![数据通信抓包](https://github.com/Lancger/opslinux/blob/master/images/tcpdump2.png)
  
  ```
14:52:39.773434 IP npsc-220.ndmp > 192.168.11.223.55081: Flags [P.], seq 821610650:821610676, ack 1925249826, win 114, options [nop,nop,TS val 20312985 ecr 11741994], length 26 

14:52:39.774208 IP 192.168.11.223.55081 > npsc-220.ndmp: Flags [.], ack 821610676, win 229, options [nop,nop,TS val 11761994 ecr 20312985], length 0

  ```
由于代码中服务端建立连接后直接给客户端发送本地时间的数据给客户端，所以上面第一行中的信息可以看出由npsc-220(服务端)发送数据给客户端192.168.11.223,请求序号为：821610650:821610676 共26个字节，

第二行表示客户端223收到数据后给服务端的发送了一个ack的确认信息


下图显示了断开连接的通信过程(其中客户端代表被动断开的一端，服务端代表主动断开的一端)

  ![断开通信抓包](https://github.com/Lancger/opslinux/blob/master/images/tcpdump3.png)

由于我的程序是由服务端主动关闭连接，所以和下图的四次握手示意图稍微有些差别

第一行显示：服务端(npsc-220)主动发送了一个FIN给客户端192.168.11.223,对应下图的FIN M ,其中M的值为821610676

第二行显示：客户端192.168.11.223确认了服务端的821610676（即下图的ACK M+1, 即ack 821610677），并发送了一个FIN给服务端，对应下图的FIN N 

第三行显示：服务端(npsc-220)确认了客户端的FIN  ack 19252429827，即下图的ACK N+1 ,

下图是断开连接的四次握手示意图

  ![TCP四次挥手](https://github.com/Lancger/opslinux/blob/master/images/tcpdump4.png)


参考文档：

https://blog.csdn.net/fly542/article/details/41348421
