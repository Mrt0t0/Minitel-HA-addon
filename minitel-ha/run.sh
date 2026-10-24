#!/usr/bin/with-contenv bashio
set -e

HA_URL=""
HA_TOKEN=""
WEATHER=""
bashio::config.has_value 'ha_url'         && HA_URL=$(bashio::config 'ha_url')
bashio::config.has_value 'ha_token'       && HA_TOKEN=$(bashio::config 'ha_token')
bashio::config.has_value 'weather_entity' && WEATHER=$(bashio::config 'weather_entity')
SPLASH=$(bashio::config 'splash_seconds')
ROTATE=$(bashio::config 'auto_rotate')
LANG_A=$(bashio::config 'language')
AUTODISC=$(bashio::config 'auto_discovery')

# Sans token personnel, on passe par l'API Core du Supervisor
# (homeassistant_api: true) : aucun Long-Lived Access Token a creer.
if [ -n "${HA_TOKEN}" ] && [ -z "${HA_URL}" ]; then
  HA_URL="http://homeassistant:8123"
fi
if [ -z "${HA_TOKEN}" ]; then
  if [ -n "${SUPERVISOR_TOKEN:-}" ]; then
    HA_URL="http://supervisor/core"
    HA_TOKEN="${SUPERVISOR_TOKEN}"
    bashio::log.info "Connexion a Home Assistant via le Supervisor."
  else
    bashio::log.warning "Ni 'ha_token' ni token Supervisor : Home Assistant sera injoignable."
  fi
fi

# Les pages .vdt sont lues depuis /share/minitel-ha/archives (persistant)
ARCH=/share/minitel-ha/archives
mkdir -p "${ARCH}"
rm -rf /app/static/archives
ln -s "${ARCH}" /app/static/archives

# config.yaml genere : conserve devices/sensors si discover.py a deja tourne
# On peut aussi y ajouter scenes, scripts, quick_off, area_order et meteo
# (voir DOCS.md) : ces cles sont reprises a chaque demarrage.
if [ ! -f /share/minitel-ha/config.yaml ]; then
  cat > /share/minitel-ha/config.yaml << YAML
devices:
sensors:
# scenes:
#   - name: "Cinema"
#     entity: scene.cinema
# scripts:
#   - name: "Alarme OFF"
#     entity: script.alarme_off
# quick_off:
#   entity: scene.tout_eteindre
#   name: "Tout eteindre"
# area_order: [Salon, Chambre, Cuisine, Autres]
# meteo:
#   sensors:
#     temperature_ext: sensor.exterieur_temperature
#     humidity_ext: sensor.exterieur_humidite
#     rooms:
#       Salon: {temp: sensor.salon_temperature, hum: sensor.salon_humidite}
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
    bashio::log.warning "Decouverte auto ignoree : aucun token Home Assistant disponible."
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

# Fusionne la configuration persistee dans /share
python3 - << 'PYEOF'
import yaml
app = yaml.safe_load(open('/app/config.yaml', encoding='utf-8')) or {}
try:
    shared = yaml.safe_load(open('/share/minitel-ha/config.yaml', encoding='utf-8')) or {}
except Exception:
    shared = {}
app['devices'] = shared.get('devices') or []
app['sensors'] = shared.get('sensors') or []
for key in ('scenes', 'scripts', 'quick_off', 'area_order'):
    if shared.get(key):
        app[key] = shared[key]
# meteo : capteurs depuis /share, weather_entity de l'option si renseignee
meteo = dict(shared.get('meteo') or {})
if app['meteo'].get('weather_entity'):
    meteo['weather_entity'] = app['meteo']['weather_entity']
app['meteo'] = meteo
yaml.dump(app, open('/app/config.yaml', 'w', encoding='utf-8'),
          allow_unicode=True, sort_keys=False)
PYEOF

bashio::log.info "Minitel-HA v$(bashio::addon.version) - 3615 MAISON - demarrage"
exec python3 /app/server.py
