FROM --platform=$BUILDPLATFORM alpine:latest

ARG TARGET VERSION TARGETOS TARGETARCH

ENV TARGET=${TARGET}
ENV FRP_FILE=frp_${VERSION}_${TARGETOS}_${TARGETARCH}

RUN cd /tmp \
    && wget https://github.com/fatedier/frp/releases/download/v${VERSION}/${FRP_FILE}.tar.gz \
    && tar -xf ${FRP_FILE}.tar.gz \
    && cd ./${FRP_FILE} \
    && cp ./${TARGET} /usr/bin/${TARGET} \
    && chmod +x /usr/bin/${TARGET} \
    && mkdir /etc/frp \
    && cp ./${TARGET}*.ini /etc/frp/ \
    && rm -rf /tmp/${FRP_FILE}*

ENTRYPOINT /usr/bin/${TARGET} -c /etc/frp/${TARGET}.ini
