FROM alpine:latest

ARG RCLONE_VERSION=1.68.0

ARG TARGETPLATFORM

# install rclone
RUN apk add --no-cache wget ca-certificates && \
    if [ "$TARGETPLATFORM" = "linux/amd64" ]; then ARCHITECTURE=amd64; elif [ "$TARGETPLATFORM" = "linux/arm/v7" ]; then ARCHITECTURE=arm-v7; elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then ARCHITECTURE=arm64; else ARCHITECTURE=amd64; fi && \
    wget -q https://downloads.rclone.org/v${RCLONE_VERSION}/rclone-v${RCLONE_VERSION}-linux-${ARCHITECTURE}.zip && \
    unzip rclone-v${RCLONE_VERSION}-linux-${ARCHITECTURE}.zip && \
    mv rclone-v${RCLONE_VERSION}-linux-${ARCHITECTURE}/rclone /usr/bin && \
    rm rclone-v${RCLONE_VERSION}-linux-${ARCHITECTURE}.zip && \
    rm -rf rclone-v${RCLONE_VERSION}-linux-${ARCHITECTURE} && \
    apk del wget

# install entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# defaults env vars
ENV CRON_SCHEDULE="0 0 * * *"
ENV COMMAND="rclone version"

CMD CRONJOB="$CRON_SCHEDULE $COMMAND" && echo "$CRONJOB" > /etc/crontabs/root && crond -f
