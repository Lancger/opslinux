```
diff -qs <(ssh-keygen -yf id_rsa) <(cut -d ' ' -f 1,2 id_rsa.pub)

Files /dev/fd/63 and /dev/fd/62 are identical     --- 这个表示key文件匹配


diff -qs <(ssh-keygen -yf ~/.ssh/id_rsa) <(cut -d ' ' -f 1,2 ~/.ssh/id_rsa.pub)

以“-----BEGIN PUBLIC KEY-----”开头 “-----END PUBLIC KEY-----” 结尾

这种格式的需要使用openssl生成

openssl genrsa -out id_rsa 1024
openssl rsa -in id_rsa -pubout -out id_rsa.pub

至于验证id_rsa.pub和id_rsa是否匹配的方法如下：

ssh-keygen  -y -f id_rsa > id_rsa.pub.tobecompared

然后比较id_rsa.pub.tobecompared 与 id_rsa.pub 的内容是否一致


```

参考文档：

https://segmentfault.com/q/1010000008302009  怎么验证id_rsa.pub和id_rsa是否匹配

https://blog.csdn.net/u010472499/article/details/53915683  检验公钥和私钥是否配对 

https://stackoverflow.com/questions/274560/how-do-you-test-a-public-private-dsa-keypair
