# 一、check_ssl.sh

```
cat > /tmp/check_ssl.sh << \EOF
#!/bin/sh 
if [[ "$1" = "" || "$2" = "" ]]; then 
    echo "certCheck.sh certfile keyfile" exit 0; 
else 
    value=`openssl x509 -text -noout -in $1 | grep "Public Key Algorithm:" | awk -F ':' 'BEGIN {}  {print $2} END {}'`

    if [ "$value" = " rsaEncryption" ] ; then 
        echo $value 
        requestModuleMd5=`openssl x509 -modulus -in $1 | grep Modulus | openssl md5` 
        privateModuleMd5=`openssl rsa -noout -modulus -in $2 | openssl md5` 
    else `openssl ec -in $2 -pubout -out ecpubkey.pem ` 
        privateModuleMd5=`cat ecpubkey.pem | openssl md5` 
        requestModuleMd5=`openssl x509 -in $1 -pubkey -noout | openssl md5` 
    fi 
    if [ "$requestModuleMd5" = "$privateModuleMd5" ] ; then 
        echo "ok" 
    fi 
fi 
EOF

```
```
#使用方法
cd /tmp/
chmod +x /tmp/check_ssl.sh
./check_ssl.sh server.pem server.key

#输出结果
rsaEncryption
ok
```

# 二、命令行校验ssl证书
```
pem=server.pem
key=server.key
(openssl x509 -noout -modulus -in $pem | openssl md5 ; openssl rsa -noout -modulus -in $key | openssl md5) | uniq

#正常结果
(stdin)= 3f3919ba18cfbbeecfbd4dfc8e24092e

#异常结果
unable to load certificate
140119833331600:error:0906D064:PEM routines:PEM_read_bio:bad base64 decode:pem_lib.c:829:
(stdin)= d41d8cd98f00b204e9800998ecf8427e
unable to load Private Key
140502187399056:error:0906D064:PEM routines:PEM_read_bio:bad base64 decode:pem_lib.c:829:
```

参考文档：

https://blog.csdn.net/tsh185/article/details/8233946 判断 证书与私钥是否匹配


https://blog.csdn.net/xiangguiwang/article/details/79977311  验证公钥证书是否和秘钥匹配
