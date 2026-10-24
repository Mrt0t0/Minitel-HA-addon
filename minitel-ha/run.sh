#!/usr/bin/with-contenv bashio
set -e

HA_URL=""
HA_TOKEN=""
WEATHER=""
ACCESS_CODE=""
bashio::config.has_value 'ha_url'         && HA_URL=$(bashio::config 'ha_url')
bashio::config.has_value 'ha_token'       && HA_TOKEN=$(bashio::config 'ha_token')
bashio::config.has_value 'weather_entity' && WEATHER=$(bashio::config 'weather_entity')
bashio::config.has_value 'access_code'    && ACCESS_CODE=$(bashio::config 'access_code')
SPLASH=$(bashio::config 'splash_seconds')
ROTATE=$(bashio::config 'auto_rotate')
LANG_A=$(bashio::config 'language')
AUTODISC=$(bashio::config 'auto_discovery')

if [ -n "${HA_TOKEN}" ] && [ -z "${HA_URL}" ]; then
  HA_URL="http://homeassistant:8123"
fi
# Sans token personnel, on passe par l'API Core du Supervisor
# (homeassistant_api: true) : aucun Long-Lived Access Token a creer.
if [ -z "${HA_TOKEN}" ]; then
  if [ -n "${SUPERVISOR_TOKEN:-}" ]; then
    HA_URL="http://supervisor/core"
    HA_TOKEN="${SUPERVISOR_TOKEN}"
    bashio::log.info "Connexion a Home Assistant via le Supervisor."
  else
    bashio::log.warning "Ni 'ha_token' ni token Supervisor : Home Assistant sera injoignable."
  fi
fi

# Les pages .vdt et le journal sont dans /share/minitel-ha (persistant)
SHARE=/share/minitel-ha
mkdir -p "${SHARE}/archives"

# Les cles de /share/minitel-ha/config.yaml (scenes, alertes, appareils...)
# sont reprises a chaque demarrage. Exemple commente cree au premier lancement.
if [ ! -f "${SHARE}/config.yaml" ]; then
  cat > "${SHARE}/config.yaml" << 'YAML'
devices:
sensors:
# scenes:
#   - name: "Cinema"
#     entity: scene.cinema
# scripts:
#   - name: "Alarme OFF"
#     entity: script.alarme_off
# quick_off:                       # touche * en mode Domotique
#   entity: scene.tout_eteindre
#   name: "Tout eteindre"
#   confirm: true
# area_order: [Salon, Chambre, Cuisine, Autres]
# alerts:                          # ligne 0 du Minitel
#   - entity: binary_sensor.porte_entree
#     state: "on"
#     message: "Porte d'entree ouverte"
#   - entity: sensor.salon_temperature
#     above: 28
#     message: "Salon trop chaud"
# meteo:
#   sensors:
#     temperature_ext: sensor.exterieur_temperature
#     humidity_ext: sensor.exterieur_humidite
#     rooms:
#       Salon: {temp: sensor.salon_temperature, hum: sensor.salon_humidite}
# display:
#   title: "   MINITEL-HA  DOMOTIQUE"
#   page_size: 9
#   show_sensors: true
# discovery:                       # entites cherchees par la decouverte
#   domains: [light, switch, cover, climate, lock, media_player, fan]
YAML
fi

cat > /app/config.yaml << YAML
homeassistant:
  url: "${HA_URL}"
  token: "${HA_TOKEN}"
server:
  vt_port: 3615
  http_port: 8080
  trust_ingress: true
display:
  page_size: 9
  refresh_auto: 30
  date_format: "%H:%M"
  show_sensors: true
  splash_seconds: ${SPLASH}
  language: "${LANG_A}"
security:
  access_code: "${ACCESS_CODE}"
archives:
  folder: "${SHARE}/archives"
  auto_rotate: ${ROTATE}
journal:
  file: "${SHARE}/journal.json"
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

# Fusionne /share/minitel-ha/config.yaml dans /app/config.yaml
merge_share() {
python3 - << 'PYEOF'
import yaml
app = yaml.safe_load(open('/app/config.yaml', encoding='utf-8')) or {}
try:
    shared = yaml.safe_load(open('/share/minitel-ha/config.yaml', encoding='utf-8')) or {}
except Exception:
    shared = {}
app['devices'] = shared.get('devices') or []
app['sensors'] = shared.get('sensors') or []
for key in ('scenes', 'scripts', 'quick_off', 'area_order', 'alerts'):
    if shared.get(key):
        app[key] = shared[key]
for key in ('display', 'discovery'):
    # Les options de l'add-on (langue, splash) gardent la priorite
    extra = {k: v for k, v in (shared.get(key) or {}).items()
             if k not in ('splash_seconds', 'language')}
    app[key] = {**app.get(key, {}), **extra}
# meteo : capteurs depuis /share, weather_entity de l'option si renseignee
meteo = dict(shared.get('meteo') or {})
if app['meteo'].get('weather_entity'):
    meteo['weather_entity'] = app['meteo']['weather_entity']
app['meteo'] = meteo
yaml.dump(app, open('/app/config.yaml', 'w', encoding='utf-8'),
          allow_unicode=True, sort_keys=False)
PYEOF
}
merge_share

# ---------------------------------------------------------------------------
# Decouverte automatique au premier demarrage (aucune entite connue).
# discover.py ecrit dans /share/minitel-ha/config.yaml (MINITEL_DISCOVER_TARGET)
# puis la fusion est refaite : les entites sont actives des ce demarrage.
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
      merge_share
      bashio::log.info "Decouverte terminee - entites actives des ce demarrage."
    else
      bashio::log.warning "Decouverte auto echouee - verifiez 'ha_url' et 'ha_token'."
      bashio::log.warning "L'add-on demarre quand meme, avec des listes vides."
    fi
  fi
fi

if [ -n "${ACCESS_CODE}" ]; then
  bashio::log.info "Code d'acces actif (Minitel et navigateur hors ingress)."
fi
bashio::log.info "Minitel-HA v$(bashio::addon.version) - 3615 MAISON - demarrage"
exec python3 /app/server.py
