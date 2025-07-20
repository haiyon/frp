# FRP Docker Images Builder

Multi-architecture Docker images builder for [FRP (Fast Reverse Proxy)](https://github.com/fatedier/frp).

## Usage

Simply run the build script:

```bash
./build.sh
```

### Custom Configuration

You can customize the build process using environment variables:

```bash
VERSION=0.63.0 REGISTRY=ghcr.io NAMESPACE=myorg ./build.sh
```

Available environment variables:

- `VERSION`: FRP version
- `REGISTRY`: Docker registry (default: docker.io)
- `NAMESPACE`: Image namespace (default: haiyon)
- `PLATFORMS`: Target platforms (default: linux/amd64,linux/arm64)

### Running Containers

FRP Server:

```bash
docker run -d --name frps \
  -p 7000:7000 -p 7500:7500 \
  -v /path/to/frps.toml:/etc/frp/frps.toml \
  haiyon/frps:latest
```

FRP Client:

```bash
docker run -d --name frpc \
  -v /path/to/frpc.toml:/etc/frp/frpc.toml \
  haiyon/frpc:latest
```

## Configuration Examples

### Server (frps.toml)

```toml
bindPort = 7000
vhostHTTPPort = 80
transport.tls.force = true

webServer.port = 7500
webServer.user = "admin"
webServer.password = "admin"
```

### Client (frpc.toml)

```toml
serverAddr = "127.0.0.1"
serverPort = 7000

[[proxies]]
name = "web"
type = "http"
localPort = 80
customDomains = ["web.yourdomain.com"]

[[proxies]]
name = "ssh"
type = "tcp"
localIP = "127.0.0.1"
localPort = 22
remotePort = 6000
```

## Acknowledgments

- [FRP Project](https://github.com/fatedier/frp)
- Docker & Docker Buildx
- Alpine Linux
