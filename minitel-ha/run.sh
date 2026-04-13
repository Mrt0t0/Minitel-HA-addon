#!/usr/bin/with-contenv bashio
set -e

HA_URL=$(bashio::config 'ha_url')
HA_TOKEN=$(bashio::config 'ha_token')
SPLASH=$(bashio::config 'splash_seconds')
ROTATE=$(bashio::config 'auto_rotate')
LANGUAGE=$(bashio::config 'language')
WEATHER_ENTITY=$(bashio::config 'weather_entity')
ASSISTANT_AGENT_ID=$(bashio::config 'assistant_agent_id')
ASSISTANT_AGENT_NAME=$(bashio::config 'assistant_agent_name')

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

assistant:
  language: "${LANGUAGE}"
  agents:
    - id: "${ASSISTANT_AGENT_ID}"
      name: "${ASSISTANT_AGENT_NAME}"

meteo:
  weather_entity: "${WEATHER_ENTITY}"
YAML

bashio::log.info "Découverte automatique des entités Home Assistant"
python3 /app/discover.py

bashio::log.info "Démarrage Minitel-HA — 3615 MAISON"
exec python3 /app/server.py
