ARG BUILD_FROM
FROM $BUILD_FROM

RUN apk add --no-cache python3 py3-pip
RUN pip3 install --no-cache-dir aiohttp websockets pyyaml

WORKDIR /app
COPY . /app/
RUN chmod +x /app/run.sh
CMD ["/app/run.sh"]
