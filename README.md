# frp

## Usage

### frps

```shell
docker run --restart=always --network host -d -v ./frps.ini:/etc/frp/frps.ini --name frps haiyon/frps
```

### frpc

```shell
docker run --restart=always --network host -d -v ./frpc.ini:/etc/frp/frpc.ini --name frpc haiyon/frpc
```
