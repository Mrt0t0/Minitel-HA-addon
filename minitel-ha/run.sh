#!/usr/bin/with-contenv bashio
set -e
HA_URL=$(bashio::config 'ha_url')
HA_TOKEN=$(bashio::config 'ha_token')
SPLASH=$(bashio::config 'splash_seconds')
ROTATE=$(bashio::config 'auto_rotate')
LANG=$(bashio::config 'language')

cat > /app/config.yaml << YAML
homeassistant:
  url: "${HA_URL}"
  token: "${HA_TOKEN}"
server:
  vt_port: 3615
  http_port: 8080
display:
  splash_seconds: ${SPLASH}
archives:
  folder: "static/archives"
  auto_rotate: ${ROTATE}
A:
  language: "${LANG}"
  agents:
    - id: "home_assistant"
      name: "Assistant HA"
meteo:
  weather_entity: "weather.forecast_maison"
YAML

bashio::log.info "Démarrage Minitel-HA — 3615 MAISON"
exec python3 /app/server.py
