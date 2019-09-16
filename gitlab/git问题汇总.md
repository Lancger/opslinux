## 1、Git版本导致的

```
root># git clone https://github.com/simplresty/ngx_devel_kit.git
Initialized empty Git repository in /usr/local/src/ngx_devel_kit/.git/
error:  while accessing https://github.com/simplresty/ngx_devel_kit.git/info/refs

fatal: HTTP request failed

#问题原因是：是curl 版本问题，更新curl版本后问题解决（或者升级git版本）

yum update -y nss curl libcurl
```
