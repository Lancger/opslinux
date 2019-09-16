# 一、系统

   1.系统最大打开文件描述符数： /proc/sys/fs/file-max

   2.查看：
   
    cat /proc/sys/fs/file-max

   3.重新设置：

    ①临时性： 

    echo 1000000 > /proc/sys/fs/file-max

    ②永久性：
    
    在配置文件/etc/sysctl.conf中设置

    fs.file-max = 1000000


# 二：进程

  1.进程最多打开文件描述符数：user limit中的 nofile 的soft limit

  2.查看:
  
  ulimit -n

  3.设置：

    ①临时性：通过 ulimit -Sn 设置最大打开文件描述符的soft limit，注意 soft limit 不能大于 hard limit
    
    ulimit -Hn可查看 hard limit，另外 ulimit-n 默认查看的是 soft limit，
    
    但是 ulimit -n 180000 则是同时设置foft limit和hard limit。
   
    对于非root用户只能设置比原来小的hard limit。

    A：查看hard limit：$ ulimit -Hn

    B：设置soft limit,必须小于hard limit:

    ulimit -Sn 160000

    ②永久性：
    
    上面的方法只是临时性的，注销重新登录就失效了，而且不能增大hard limit，只能在hard limit范围内修改soft limit，
    
    若要永久修改，则需要在/etc/security/limits.conf中进行设置（root用户），可添加如下两行，
    
    表示所有用户最大打开文件描述符数的soft limit为102400，hard limit为1040800.
    
    设置需要注销之后重新登录才能生效：

    在etc/security/limits.conf中添加如下内容：
     
    *soft nofile 102400
    *hard nofile 104800

    注意：设置nofile的hard limit还要注意一点的就是hard limit不能大于/proc/sys/fs/nr_open，加入hard大于nr_open，注销                        
    
    后将无法正常登陆。

    可以修改nr_open的值：# echo 200000 > /pro/sys/fs/nr_open
    
             
 # 三、查看当前系统使用的打开文件符数

    cat /proc/sys/fs/file-nr

    5664   0   186405

   其中第一个数表示当前系统已分配使用的打开文件描述符数，第二个数为分配后已释放的（目前已不再使用），第三个数等于file-max 

# 四、总结

  》1.所有进程打开的文件描述符数不能超过/proc/sys/fs/file-max

  》2.单个进程打开的文件描述符数不能超过user limit中的nofile的soft limit

  》3.nofile的soft limit不能超过其hard limit

  》4.nofile的hard limt 不能超过 /proc/sys/fs/nr_open.
  
  
参考资料：

https://blog.csdn.net/genzld/article/details/86564821   Linux最大文件描述符数
