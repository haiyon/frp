FROM --platform=$BUILDPLATFORM alpine:3.19 AS builder

ARG TARGET VERSION TARGETOS TARGETARCH
ARG FRP_FILE=frp_${VERSION}_${TARGETOS}_${TARGETARCH}

# Download and extract FRP
WORKDIR /tmp
RUN wget -q https://github.com/fatedier/frp/releases/download/v${VERSION}/${FRP_FILE}.tar.gz \
  && tar -xf ${FRP_FILE}.tar.gz \
  && cd ./${FRP_FILE} \
  && cp ./${TARGET} /tmp/${TARGET} \
  && cp ./${TARGET}*.toml /tmp/

# Final stage
FROM alpine:3.19
ARG TARGET
ENV TARGET=${TARGET}

# Create directories and add non-root user
RUN adduser -D -H -s /sbin/nologin frp \
  && mkdir -p /etc/frp \
  && chown -R frp:frp /etc/frp

# Copy binary and config from builder
COPY --from=builder /tmp/${TARGET} /usr/bin/${TARGET}
COPY --from=builder /tmp/${TARGET}.toml /etc/frp/

# Set permissions
RUN chmod +x /usr/bin/${TARGET}

WORKDIR /etc/frp
USER frp

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD pgrep ${TARGET} || exit 1

EXPOSE 7000 7500

ENTRYPOINT ["/usr/bin/${TARGET}", "-c", "/etc/frp/${TARGET}.toml"]
