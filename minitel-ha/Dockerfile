ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:3.19
FROM $BUILD_FROM
RUN apk add --no-cache python3 py3-pip \
 && pip3 install --no-cache-dir --break-system-packages aiohttp websockets pyyaml
WORKDIR /app
COPY . /app/
RUN chmod +x /app/run.sh
CMD ["/app/run.sh"]
