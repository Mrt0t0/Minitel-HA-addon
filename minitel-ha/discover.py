import sys
from pathlib import Path
import yaml
import asyncio
import aiohttp

# Variante add-on Home Assistant : /app/config.yaml est regenere a chaque
# demarrage par run.sh (source = /share/minitel-ha/config.yaml). Ecrire ici
# les entites decouvertes doit donc cibler /share, pas /app, sous peine de
# perdre le travail de decouverte au prochain redemarrage de l'add-on.
APP_CFG   = Path('/app/config.yaml')
SHARE_CFG = Path('/share/minitel-ha/config.yaml')

app_cfg = yaml.safe_load(open(APP_CFG, encoding='utf-8')) or {}
HA_URL  = app_cfg['homeassistant']['url']
HA_TOK  = app_cfg['homeassistant']['token']
HDRS    = {'Authorization': f'Bearer {HA_TOK}', 'Content-Type': 'application/json'}

disc     = app_cfg.get('discovery') or {}
DOMAINS  = disc.get('domains', ['light', 'switch'])
SEN_CLS  = disc.get('sensor_classes', ['temperature', 'humidity'])
EXCL_KW  = disc.get('exclude_keywords', [])
EXCL_IDS = disc.get('exclude_entities', [])
FORCE    = '--force' in sys.argv
DRY_RUN  = '--dry' in sys.argv


async def area_of(session, eid):
    tpl = "{{ area_name('" + eid + "') }}"
    try:
        async with session.post(f'{HA_URL}/api/template', headers=HDRS,
                                json={'template': tpl}) as r:
            v = (await r.text()).strip()
        return v if v and v.lower() != 'none' else 'Autres'
    except Exception:
        return 'Autres'


async def run():
    async with aiohttp.ClientSession() as session:
        async with session.get(f'{HA_URL}/api/states', headers=HDRS) as r:
            if r.status != 200:
                print(f'[ERR] HA non joignable : {r.status}')
                return
            states = await r.json()

    devices_raw = [e for e in states
                   if e['entity_id'].split('.')[0] in DOMAINS
                   and not any(kw in e['entity_id'] for kw in EXCL_KW)
                   and e['entity_id'] not in EXCL_IDS]
    sensors_raw = [e for e in states
                   if e['entity_id'].split('.')[0] == 'sensor'
                   and e['attributes'].get('device_class') in SEN_CLS]

    print(f"\n{'='*50}\n  Decouverte add-on -> ecriture dans {SHARE_CFG}\n{'='*50}")
    print(f'  {len(devices_raw)} appareils | {len(sensors_raw)} capteurs\n')

    SHARE_CFG.parent.mkdir(parents=True, exist_ok=True)
    shared = {}
    if SHARE_CFG.exists():
        shared = yaml.safe_load(open(SHARE_CFG, encoding='utf-8')) or {}
    existing_devices = {d['entity']: d for d in (shared.get('devices') or [])}
    existing_sensors = {s['entity']: s for s in (shared.get('sensors') or [])}

    merged_devices, merged_sensors = [], []
    seen_d, seen_s = set(), set()

    async with aiohttp.ClientSession() as session:
        for e in devices_raw:
            eid   = e['entity_id']
            fname = e['attributes'].get('friendly_name', eid)
            area  = await area_of(session, eid)
            icon  = 'light' if eid.startswith('light') else 'switch'
            ex    = existing_devices.get(eid, {})
            seen_d.add(eid)
            if FORCE or not ex:
                merged_devices.append({'entity': eid, 'name': fname, 'area': area,
                                       'icon': icon, 'visible': True})
            else:
                merged_devices.append({'entity': eid, 'name': ex.get('name', fname),
                                       'area': ex.get('area', area), 'icon': icon,
                                       'visible': ex.get('visible', True)})
        for eid, d in existing_devices.items():
            if eid not in seen_d:
                d2 = dict(d); d2['visible'] = False
                merged_devices.append(d2)

        for e in sensors_raw:
            eid   = e['entity_id']
            fname = e['attributes'].get('friendly_name', eid)
            area  = await area_of(session, eid)
            ex    = existing_sensors.get(eid, {})
            seen_s.add(eid)
            if FORCE or not ex:
                merged_sensors.append({
                    'entity': eid, 'name': fname, 'area': area,
                    'unit': e['attributes'].get('unit_of_measurement', ''),
                    'class': e['attributes'].get('device_class', 'sensor'),
                    'visible': True})
            else:
                merged_sensors.append({
                    'entity': eid, 'name': ex.get('name', fname),
                    'area': ex.get('area', area), 'unit': ex.get('unit', ''),
                    'class': ex.get('class', 'sensor'),
                    'visible': ex.get('visible', True)})
        for eid, s in existing_sensors.items():
            if eid not in seen_s:
                s2 = dict(s); s2['visible'] = False
                merged_sensors.append(s2)

    print(f'  {len(merged_devices)} appareils | {len(merged_sensors)} capteurs')
    if DRY_RUN:
        print('  [DRY RUN] rien ecrit')
        return

    shared['devices'] = merged_devices
    shared['sensors'] = merged_sensors
    with open(SHARE_CFG, 'w', encoding='utf-8') as f:
        yaml.dump(shared, f, allow_unicode=True, default_flow_style=False,
                  sort_keys=False)
    print(f"OK {SHARE_CFG} mis a jour - redemarrez l'add-on pour appliquer")


asyncio.run(run())
