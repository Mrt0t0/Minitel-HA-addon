# Minitel-HA — 3615 MAISON

Contrôlez Home Assistant depuis un vrai Minitel (WebSocket `:3615`) ou depuis l'émulateur Minitel du navigateur (barre latérale de HA, ou port `:8080`).

## Installation

1. **Paramètres** → **Modules complémentaires** → **Boutique** → menu ⋮ → **Dépôts**
2. Ajouter : `https://github.com/Mrt0t0/Minitel-HA-addon`
3. Installer **Minitel-HA** puis **Démarrer** (aucune option obligatoire)
4. Ouvrir **Minitel** dans la barre latérale

Au premier démarrage, les lampes et prises sont découvertes automatiquement.

## Options

| Option | Description |
|---|---|
| `ha_url` | Facultatif. URL d'une autre instance HA (défaut `http://homeassistant:8123` si `ha_token` est renseigné) |
| `ha_token` | Facultatif. Long-Lived Access Token. Vide : le token Supervisor est utilisé |
| `access_code` | Facultatif. Code demandé sur le Minitel et dans le navigateur par le port 8080 (pas via la barre latérale) |
| `auto_discovery` | Découverte des entités au premier démarrage |
| `splash_seconds` | Durée de l'écran d'accueil, 0 à 60 s |
| `auto_rotate` | Rotation auto des pages `.vdt` en mode Archives (0 = désactivé) |
| `language` | Langue des écrans et de l'assistant (`fr` / `en`) |
| `weather_entity` | Facultatif. Entité météo HA pour les prévisions |

## Accès

- Barre latérale de Home Assistant : **Minitel** (ingress, sans code d'accès)
- Navigateur : `http://[IP_HA]:8080`
- Minitel / ESP32 : `ws://[IP_HA]:3615`

## Données et réglages persistants

Le dossier `/share/minitel-ha/` survit aux mises à jour et redémarrages :

- `archives/` — pages Vidéotex `.vdt` (aussi déposables depuis l'émulateur : bouton `.vdt ⇪`)
- `journal.json` — journal des actions
- `config.yaml` — appareils et capteurs découverts, et les réglages ci-dessous (un exemple commenté est créé au premier démarrage) :

```yaml
scenes:
  - name: "Cinéma"
    entity: scene.cinema
quick_off:                      # touche * en mode Domotique
  entity: scene.tout_eteindre
  name: "Tout éteindre"
  confirm: true
area_order: [Salon, Chambre, Cuisine, Autres]
alerts:                         # ligne 0 du Minitel
  - entity: binary_sensor.porte_entree
    state: "on"
    message: "Porte d'entrée ouverte"
  - entity: sensor.salon_temperature
    above: 28
    message: "Salon trop chaud"
meteo:
  sensors:
    temperature_ext: sensor.exterieur_temperature
    rooms:
      Salon: {temp: sensor.salon_temperature, hum: sensor.salon_humidite}
display:
  title: "   MINITEL-HA  DOMOTIQUE"
  show_sensors: true
discovery:                      # types cherchés par la découverte
  domains: [light, switch, cover, climate, lock, media_player, fan]
```

Redémarrez l'add-on après modification.

## Découverte des entités

Depuis un terminal sur l'hôte HA :

```bash
docker exec addon_minitel_ha python3 /app/discover.py          # --dry : aperçu sans écrire
```

La commande écrit dans `/share/minitel-ha/config.yaml`. Les noms, pièces et visibilités que vous avez modifiés sont conservés ; les entités disparues de HA sont masquées. **Redémarrez l'add-on** ensuite.

---

# English

Control Home Assistant from a real Minitel (WebSocket `:3615`) or from the Minitel emulator in your browser (HA sidebar, or port `:8080`).

## Installation

1. **Settings** → **Add-ons** → **Add-on store** → ⋮ → **Repositories**
2. Add: `https://github.com/Mrt0t0/Minitel-HA-addon`
3. Install **Minitel-HA** and **Start** it (no option is required)
4. Open **Minitel** in the sidebar

Lights and switches are discovered automatically on first start.

## Options

| Option | Description |
|---|---|
| `ha_url` | Optional. URL of another HA instance (defaults to `http://homeassistant:8123` when `ha_token` is set) |
| `ha_token` | Optional. Long-Lived Access Token. Empty: the Supervisor token is used |
| `access_code` | Optional. Code asked on the Minitel and in the browser through port 8080 (not through the sidebar) |
| `auto_discovery` | Entity discovery on first start |
| `splash_seconds` | Splash screen duration, 0 to 60 s |
| `auto_rotate` | Auto-rotation of `.vdt` pages in Archives mode (0 = off) |
| `language` | Screens and assistant language (`fr` / `en`) |
| `weather_entity` | Optional. HA weather entity used for forecasts |

## Access

- Home Assistant sidebar: **Minitel** (ingress, no access code)
- Browser: `http://[HA_IP]:8080`
- Minitel / ESP32: `ws://[HA_IP]:3615`

## Persistent data and settings

`/share/minitel-ha/` survives add-on updates and restarts: `archives/` (`.vdt` pages, also uploadable from the emulator), `journal.json` (action journal) and `config.yaml` (discovered devices and sensors, plus `scenes`, `scripts`, `quick_off`, `area_order`, `alerts`, `meteo`, `display`, `discovery` — see the French example above). Restart the add-on after editing it.

## Entity discovery

```bash
docker exec addon_minitel_ha python3 /app/discover.py          # --dry: preview only
```

This writes to `/share/minitel-ha/config.yaml` and keeps your customisations. **Restart the add-on** afterwards.
