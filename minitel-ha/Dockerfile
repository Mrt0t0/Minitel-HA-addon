ARG BUILD_FROM
FROM $BUILD_FROM

RUN apk add --no-cache \
    python3 \
    py3-aiohttp \
    py3-websockets \
    py3-yaml

WORKDIR /app
COPY . /app/
RUN chmod +x /app/run.sh

CMD ["/app/run.sh"]
