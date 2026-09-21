#!/usr/bin/with-contenv bashio
set -e

HA_URL=$(bashio::config 'ha_url')
HA_TOKEN=$(bashio::config 'ha_token')
SPLASH=$(bashio::config 'splash_seconds')
ROTATE=$(bashio::config 'auto_rotate')
LANG_A=$(bashio::config 'language')
WEATHER=$(bashio::config 'weather_entity')
AUTODISC=$(bashio::config 'auto_discovery')

# Les pages .vdt sont lues depuis /share/minitel-ha/archives (persistant)
ARCH=/share/minitel-ha/archives
mkdir -p "${ARCH}"
rm -rf /app/static/archives
ln -s "${ARCH}" /app/static/archives

# config.yaml genere : conserve devices/sensors si discover.py a deja tourne
if [ ! -f /share/minitel-ha/config.yaml ]; then
  cat > /share/minitel-ha/config.yaml << YAML
devices:
sensors:
YAML
fi

cat > /app/config.yaml << YAML
homeassistant:
  url: "${HA_URL}"
  token: "${HA_TOKEN}"
server:
  vt_port: 3615
  http_port: 8080
display:
  page_size: 9
  refresh_auto: 30
  date_format: "%H:%M"
  show_sensors: true
  splash_seconds: ${SPLASH}
archives:
  folder: "static/archives"
  auto_rotate: ${ROTATE}
assistant:
  language: "${LANG_A}"
  agents:
    - id: "conversation.home_assistant"
      name: "Assistant HA"
meteo:
  weather_entity: "${WEATHER}"
discovery:
  domains: [light, switch]
  sensor_classes: [temperature, humidity]
  exclude_keywords: [_energy, _power, _current, _voltage, _rssi, _wifi]
  exclude_entities: []
YAML

# ---------------------------------------------------------------------------
# Decouverte automatique au premier demarrage
# Se declenche si /share/minitel-ha/config.yaml ne contient encore aucune
# entite. Placee AVANT la fusion ci-dessous : les entites trouvees sont donc
# actives immediatement, sans redemarrage de l'add-on.
# ---------------------------------------------------------------------------
NEEDS_DISCOVERY=$(python3 - << 'PYEOF'
import yaml
try:
    c = yaml.safe_load(open('/share/minitel-ha/config.yaml', encoding='utf-8')) or {}
except Exception:
    c = {}
print('1' if not (c.get('devices') or c.get('sensors')) else '0')
PYEOF
)

if [ "${NEEDS_DISCOVERY}" = "1" ]; then
  if [ "${AUTODISC}" != "true" ]; then
    bashio::log.info "Aucune entite connue - decouverte auto desactivee (auto_discovery: false)."
  elif [ -z "${HA_TOKEN}" ]; then
    bashio::log.warning "Decouverte auto ignoree : 'ha_token' est vide (Profil HA -> Securite)."
  else
    bashio::log.info "Premier demarrage : decouverte automatique des entites..."
    if python3 /app/discover.py; then
      bashio::log.info "Decouverte terminee - entites actives des ce demarrage."
    else
      bashio::log.warning "Decouverte auto echouee - verifiez 'ha_url' et 'ha_token'."
      bashio::log.warning "L'add-on demarre quand meme, avec des listes vides."
    fi
  fi
fi

# Fusionne devices/sensors persistes
python3 - << 'PYEOF'
import yaml
app = yaml.safe_load(open('/app/config.yaml')) or {}
try:
    shared = yaml.safe_load(open('/share/minitel-ha/config.yaml')) or {}
except Exception:
    shared = {}
app['devices'] = shared.get('devices') or []
app['sensors'] = shared.get('sensors') or []
yaml.dump(app, open('/app/config.yaml','w'), allow_unicode=True, sort_keys=False)
PYEOF

bashio::log.info "Minitel-HA v1.1 - 3615 MAISON - demarrage"
exec python3 /app/server.py
