# 一、安装环境(docker-compose方式部署consul集群)

1、基础环境准备
```
# 1、Install Compose
setenforce 0
export Version="1.24.0"
curl -L "https://github.com/docker/compose/releases/download/${Version}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version

docker rm -f `docker ps -a -q`

docker-compose up -d
```

2、各种token介绍
```
acl_master_token有最高权限，
acl_token用于请求资源是通过分配得到的Token，这个Token的只有一些资源的操作权限，例如：某个key的读权限。
acl_master_token是启动ACL是提供的Token。
acl_agent_token则是通过api进行请求获取，然后给后续加入集群中的agent，用与完成agent的acl认证。
```

  ![consul-token](https://github.com/Lancger/opslinux/blob/master/images/consul-acl-token.png)

3、api方式添加token
```
curl \
    --request PUT \
    --header "X-Consul-Token: 2a825e81-b249-444d-a18e-ab9c8ece6059" \
    --data \
'{
  "Name": "Agent Token",
  "Type": "client",
  "Rules": "node \"\" { policy = \"write\" } service \"\" { policy = \"read\" }"
}' http://127.0.0.1:8500/v1/acl/create

{"ID": "your-agent-token"}
```

# 二、带acl的示例

1、创建目录和acl文件

```
mkdir -p /data0/consul/conf_with_acl

cd /data0/consul/conf_with_acl/

cat > acl.json << \EOF
{
    "acl_datacenter": "dc1",
    "acl_master_token": "2a825e81-b249-444d-a18e-ab9c8ece6059"
}
EOF
```

2、创建docker-compose.yaml文件

```
cat > /data0/consul/docker-compose.yaml << \EOF
version: '3'
networks:
  byfn:
 
services:
  consul1:
    image: consul
    container_name: node1
    volumes: 
      - /data0/consul/conf_with_acl:/consul/config
    command: agent -server -bootstrap-expect=3 -node=node1 -bind=0.0.0.0 -client=0.0.0.0 -config-dir=/consul/config
    networks:
      - byfn
 
  consul2:
    image: consul
    container_name: node2
    volumes:
      - /data0/consul/conf_with_acl:/consul/config
    command: agent -server -retry-join=node1 -node=node2 -bind=0.0.0.0 -client=0.0.0.0 -config-dir=/consul/config
    depends_on:
        - consul1
    networks:
      - byfn
 
  consul3:
    image: consul
    volumes:
      - /data0/consul/conf_with_acl:/consul/config
    container_name: node3
    command: agent -server -retry-join=node1 -node=node3 -bind=0.0.0.0 -client=0.0.0.0 -config-dir=/consul/config
    depends_on:
        - consul1
    networks:
      - byfn
 
  consul4:
    image: consul
    container_name: node4
    volumes:
      - /data0/consul/conf_with_acl:/consul/config
    command: agent -retry-join=node1 -node=ndoe4 -bind=0.0.0.0 -client=0.0.0.0 -ui -config-dir=/consul/config
    ports:
      - 8501:8500
    depends_on:
        - consul2
        - consul3
    networks:
      - byfn

  consul5:
    image: consul
    container_name: node5
    volumes:
      - /data0/consul/conf_without_acl:/consul/config
    command: agent -retry-join=node1 -node=ndoe5 -bind=0.0.0.0 -client=0.0.0.0 -ui -config-dir=/consul/config
    ports:
      - 8502:8500
    depends_on:
        - consul2
        - consul3
    networks:
      - byfn
EOF

cd /data0/consul/
docker-compose up -d

从docker-compose.yml可以看出Consul集群启动了5个节点，其中node1~node3作为Consul Server组成集群。node4作为客户端join到集群中，映射宿主机的8501端口到容器的8500端口ports: - 8501:8500，使得通过command参数-ui提供Consul UI，可以通过访问宿主机的8501访问。node5作为客户端join到集群,不需要token就可以访问
```

3、测试访问ui

http://192.168.56.11:8501/ui/dc1/nodes   --这个访问需要token

http://192.168.56.11:8502/ui/dc1/nodes   --这个访问不需要token，直接可以访问

# 三、不带acl的示例

```
mkdir -p /data0/consul/conf_with_acl

cat > /data0/consul/docker-compose.yaml << \EOF
version: '2'
networks:
  byfn:
 
services:
  consul1:
    image: consul
    container_name: node1
    command: agent -server -bootstrap-expect=3 -node=node1 -bind=0.0.0.0 -client=0.0.0.0 -datacenter=dc1
    networks:
      - byfn
 
  consul2:
    image: consul
    container_name: node2
    command: agent -server -retry-join=node1 -node=node2 -bind=0.0.0.0 -client=0.0.0.0 -datacenter=dc1
    depends_on:
        - consul1
    networks:
      - byfn
 
  consul3:
    image: consul
    container_name: node3
    command: agent -server -retry-join=node1 -node=node3 -bind=0.0.0.0 -client=0.0.0.0 -datacenter=dc1
    depends_on:
        - consul1
    networks:
      - byfn
 
  consul4:
    image: consul
    container_name: node4
    command: agent -retry-join=node1 -node=ndoe4 -bind=0.0.0.0 -client=0.0.0.0 -datacenter=dc1 -ui 
    ports:
      - 8500:8500
    depends_on:
        - consul2
        - consul3
    networks:
      - byfn
EOF
```
https://juejin.im/post/5d4289e1e51d45620b21c34a   Consul 集群部署 + ACL 配置
