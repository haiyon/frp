#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Configuration
VERSION="${VERSION:-0.63.0}"
REGISTRY="${REGISTRY:-docker.io}"
NAMESPACE="${NAMESPACE:-haiyon}"
PLATFORMS="${PLATFORMS:-linux/amd64,linux/arm64}"
TARGETS=("frps" "frpc")
BUILDER_NAME="frp-builder"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Helper functions
log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
    exit 1
}

# Cleanup function
cleanup() {
    if [ "$?" -ne 0 ]; then
        warn "Build failed, cleaning up..."
        docker buildx rm "${BUILDER_NAME}" 2>/dev/null || true
    fi
}

# Set trap for cleanup
trap cleanup EXIT

# Verify dependencies
check_dependencies() {
    local deps=("docker")
    for dep in "${deps[@]}"; do
        if ! command -v $dep >/dev/null 2>&1; then
            error "$dep is required but not installed"
        fi
    done

    # Verify Docker is running
    if ! docker info >/dev/null 2>&1; then
        error "Docker is not running"
    fi
}

# Verify if buildx is installed and create builder if needed
setup_buildx() {
    if ! docker buildx ls | grep -q "${BUILDER_NAME}"; then
        log "Creating new buildx builder instance"
        docker buildx create --name "${BUILDER_NAME}" --driver docker-container --bootstrap
        docker buildx use "${BUILDER_NAME}"
    else
        log "Using existing buildx builder"
        docker buildx use "${BUILDER_NAME}"
    fi
}

# Build and push images
build_and_push() {
    local target=$1
    local tags=(-t "${REGISTRY}/${NAMESPACE}/${target}:latest" -t "${REGISTRY}/${NAMESPACE}/${target}:v${VERSION}")

    log "Building ${target} version ${VERSION}"
    if ! docker buildx build \
        "${tags[@]}" \
        --build-arg TARGET="${target}" \
        --build-arg VERSION="${VERSION}" \
        --platform "${PLATFORMS}" \
        --push \
        .; then
        error "Failed to build ${target}"
    fi

    # Verify image
    log "Verifying image ${REGISTRY}/${NAMESPACE}/${target}:v${VERSION}"
    if ! docker buildx imagetools inspect "${REGISTRY}/${NAMESPACE}/${target}:v${VERSION}" >/dev/null; then
        error "Image verification failed for ${target}"
    fi

    log "Successfully built and verified ${target}"
}

# Execute build process
execute() {
    log "Starting build process for FRP version ${VERSION}"

    check_dependencies
    setup_buildx

    # Build each target
    for target in "${TARGETS[@]}"; do
        build_and_push "${target}"
    done

    # Clean up builder cache
    docker builder prune -f --filter type=exec.cachemount

    log "Build process completed successfully"
}

# Run execute function
execute
