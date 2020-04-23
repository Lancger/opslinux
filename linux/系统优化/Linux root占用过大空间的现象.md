Linux系统中/root显示大小为181G，但/root下却无大文件，重启OS后依然如此.

```
root># du -sh .[!.]*
36K     .bash_history
4.0K    .bash_logout
4.0K    .bash_profile
4.0K    .bashrc
4.0K    .bashrc-anaconda3.bak
19M     .cache
4.0K    .cshrc
8.0K    .groovy
20K     .java
9.7G    .jenkins
4.0K    .lesshst
52M     .local
960M    .m2
8.0K    .pki
4.0K    .python_history
16K     .ssh
4.0K    .tcshrc
4.0K    .viminfo



du -h --max-depth=1 /
```
参考文档：

https://blog.csdn.net/lk_db/article/details/78341698
