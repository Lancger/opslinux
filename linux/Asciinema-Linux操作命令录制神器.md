# 一、安装

注意：需要安装[python3.7环境](https://github.com/Lancger/opslinux/blob/master/python/install_python3.7.md)

```
#CentOS or RedHat
yum install epel-release -y
yum install asciinema -y   #(旧版本)

#pip 
pip3 install asciinema

#安装完成后查看版本
$ /usr/local/python3.7/bin/asciinema --version
asciinema 2.0.2

cp /usr/local/python3.7/bin/asciinema /usr/bin/

asciinema 有5个参数，分别为录制：rec，播放：play，以文件形式查看录制内容：cat，上传文件到 asciinema.org 网站：upload、asciinema.org 账号认证：auth，本文主要说明rec和play的使用。
```

# 二、录制

```bash
asciinema rec ops-audit.cast

有几个参数可以使用：

--stdin表示启用标准输入录制，意思是通常情况下linux输入密码类的信息都不会显示，如果开启了这个选项，可以记录键盘输出的密码，但这个功能官方似乎还没有支持，加了后看不到效果。

--append 添加录制到已存在的文件中。

--raw 保存原始STDOUT输出，无需定时信息等。

--overwrite 如果文件已存在，则覆盖。

-c 要记录的命令，默认为$SHELL。

-e 要捕获的环境变量列表，默认为SHELL,TERM。

-t 后跟数字，指定录像的title。

-i 后跟数字，设置录制时记录的最大空闲时间。

-y 所有提示都输入yes

-q 静默模式，加了此参数在进入录制或者退出录制时都没有提示。

输入exit或按ctrl+D组合键退出录制。
```

# 三、播放

```bash
asciinema play -s 1.5 -i 2 ops-audit.cast

有两个参数可以使用：

-s 后边跟数字，表示用几倍的速度来播放录像

-i 后边跟数字，表示在播放录像时空闲时间的最大秒数

在播放的过程中你可以通过空格来控制暂停或播放，也可以通过ctrl+c组合键来退出播放，当你按空格键暂停时，可以通过.号来逐帧显示接下来要播放的内容。
```

# 四、文件

```bash
asciinema 推荐的文件后缀是.cast，当然linux是不关心文件后缀的，你用什么都可以，推荐按规范使用.cast，文件内容大概如下

# cat ops-audit.cast
{"version": 2, "width": 237, "height": 55, "timestamp": 1572646909, "env": {"SHELL": "/bin/bash", "TERM": "linux"}, "title": "ops-coffee"}
[0.010014, "o", "root@onlinegame:~# "]
[1.296458, "o", "exit"]
[1.976439, "o", "\r\n"]
[1.976532, "o", "exit\r\n"]
cast 文件主要有两部分组成，位于第一行的一个字典，这里叫 header

{
    "version": 2,
    "width": 237,
    "height": 55,
    "timestamp": 1572646909,
    "env": {
        "SHELL": "/bin/bash",
        "TERM": "linux"
    },
    "title": "ops-audit"
}
header很简单，字段的意思分别为：version版本，width和height分别表示录制窗口的宽高，timestamp录制开始的时间戳，env录制时指定的-e参数设置，title录制时指定的-t参数设置。

接下来的都是固定格式的内容，实际上就是IO流信息

[0.010014, "o", "root@onlinegame:~# "]

每一行都是由三部分组成的一个列表

第一部分为一个浮点数，表示输入输出这一行内容所花的时间

第二部分似乎是一个固定的字符串，没有找到说明做什么用的

第三部分就是具体的输入输出的内容
这个文件格式设计还是非常优雅的，开头 header 声明，后边具体内容，如果中途因为任何意外导致录像终止，也不会丢失整个录像，而且还可以 append 增加录像，这在需要长时间暂停录制时非常有用，更重要的是可以流式读取，几乎很少占用内存，不需要把整个录像文件都放在内存中，对长时间的录制播放更友好。
```

# 五、自动录制审计日志

如果你有经历过严格的IT审计，或者有用到堡垒机，就会知道操作过程是需要记录并加入审计的，如果你有因为不知道是谁操作了什么导致了数据被删而背锅的经历，就会知道对操作过程的记录有多么的重要，接下来以一个简单的案例来介绍asciinema有什么样的实用价值。

非常简单，只需要在 devuser 用户的家目录下添加.bash_profile文件即可，内容如下：

```bash
mkdir -p /tmp/audit/

$ cat ~/.bash_profile
export LC_ALL=en_US.UTF-8
/usr/bin/asciinema rec /tmp/audit/$USER-$(date +%Y%m%d%H%M%S).log -q
```

添加export LC_ALL=en_US.UTF-8的原因是有可能系统会报错：
```bash
asciinema needs a UTF-8 native locale to run. Check the output of locale command.
```

rec命令进行录制时添加了-q 参数，这样在进入或者退出时都不会有任何关于 asciinema 的提示，使用简单方便。
这样 devuser 用户每次登陆就会自动开启一个录像，如果需要审计或检查操作，只需要回放录像就可以了。

你可能会说history命令一样可以记录用户操作，asciinema 有什么优势呢？asciinema 不仅可以记录用户的输入，还可以记录系统的输出，也就是说history只能记录执行的命令，而 asciinema 还可以记录执行的结果，怎么样，是不是很方便，赶紧试试吧。

# 六、录制上传
```
#删除服务器的认证ID
rm ~/.asciinema/install-id 
rm ~/.config/asciinema/install-id

#认证生成ID
asciinema auth
https://asciinema.org/

#开启录制并上传
asciinema rec ops-audit.cast
asciinema upload ops-audit.cast
```
参考资料：

https://www.yp14.cn/2019/11/16/Asciinema%EF%BC%9ALinux%E6%93%8D%E4%BD%9C%E5%91%BD%E4%BB%A4%E5%BD%95%E5%88%B6%E7%A5%9E%E5%99%A8/

https://mp.weixin.qq.com/s/oIKPy6zf1NXA4OfoQNkKGw 
