```bash
curl -I -m 10 -o /dev/null -s -w %{http_code} www.baidu.com

200
```
