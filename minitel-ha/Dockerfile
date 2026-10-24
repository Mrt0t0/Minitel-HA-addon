ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:3.23
FROM $BUILD_FROM
RUN apk add --no-cache python3 py3-pip
WORKDIR /app
COPY requirements.txt /app/
RUN pip3 install --no-cache-dir --break-system-packages -r /app/requirements.txt
COPY . /app/
RUN chmod +x /app/run.sh
# discover.py lit /app/config.yaml et ecrit dans /share (persistant)
ENV PYTHONUNBUFFERED=1 \
    MINITEL_CONFIG=/app/config.yaml \
    MINITEL_DISCOVER_TARGET=/share/minitel-ha/config.yaml
CMD ["/app/run.sh"]
