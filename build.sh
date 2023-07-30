# frp version
VERSION='0.51.2'
TARGET='frps frpc'

# build docker
for t in $TARGET; do
    docker buildx build -t haiyon/${t}:latest -t haiyon/${t}:v${VERSION} --build-arg TARGET=${t}  --build-arg VERSION=${VERSION} --platform linux/amd64,linux/arm64,darwin/amd64,darwin/arm64 --push .
done
