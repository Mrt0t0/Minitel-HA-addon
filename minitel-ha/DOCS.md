# Minitel-HA — 3615 MAISON

Contrôlez Home Assistant depuis un vrai Minitel (WebSocket `:3615`) ou depuis un navigateur (`:8080`).

## Installation

1. **Paramètres** → **Modules complémentaires** → **Boutique** → menu ⋮ → **Dépôts**
2. Ajouter : `https://github.com/Mrt0t0/Minitel-HA-addon`
3. Installer **Minitel-HA**, onglet **Configuration** : renseigner `ha_url` et `ha_token`
4. Démarrer l'add-on

## Options

| Option | Description |
|---|---|
| `ha_url` | URL de votre instance HA (ex. `http://homeassistant.local:8123`) |
| `ha_token` | Long-Lived Access Token (Profil → Sécurité) |
| `splash_seconds` | Durée du splash screen, 0 à 60 s |
| `auto_rotate` | Rotation auto des pages `.vdt` en mode Archives (0 = désactivé) |
| `language` | Langue de l'assistant conversationnel (`fr` / `en`) |
| `weather_entity` | Entité météo HA pour les prévisions (ex. `weather.forecast_maison`) |

## Accès

- Navigateur : `http://[IP_HA]:8080`
- Minitel / ESP32 : `ws://[IP_HA]:3615`

## Données persistantes

Le dossier `/share/minitel-ha/` survit aux mises à jour et redémarrages de l'add-on :

- `/share/minitel-ha/archives/` — déposez ici vos pages Vidéotex `.vdt`
- `/share/minitel-ha/config.yaml` — liste des appareils et capteurs découverts

## Découverte des entités

Depuis un terminal sur l'hôte HA :

```bash
docker exec addon_minitel_ha python3 /app/discover.py
```

Cette commande écrit directement dans `/share/minitel-ha/config.yaml` (et non
`/app/config.yaml`, qui est régénéré à chaque démarrage). **Redémarrez
l'add-on** ensuite pour que les nouveaux appareils apparaissent.

La fusion est non destructive : vos personnalisations (`name`, `area`,
`visible`) sont conservées à chaque nouvelle découverte.

---

# English

Control Home Assistant from a real Minitel terminal (WebSocket `:3615`) or a web browser (`:8080`).

## Installation

1. **Settings** → **Add-ons** → **Add-on store** → ⋮ → **Repositories**
2. Add: `https://github.com/Mrt0t0/Minitel-HA-addon`
3. Install **Minitel-HA**, in the **Configuration** tab set `ha_url` and `ha_token`
4. Start the add-on

## Options

| Option | Description |
|---|---|
| `ha_url` | Your HA instance URL |
| `ha_token` | Long-Lived Access Token (Profile → Security) |
| `splash_seconds` | Splash screen duration, 0 to 60 s |
| `auto_rotate` | Auto-rotation of `.vdt` pages in Archives mode (0 = off) |
| `language` | Conversational assistant language (`fr` / `en`) |
| `weather_entity` | HA weather entity used for forecasts |

## Persistent data

`/share/minitel-ha/` survives add-on updates and restarts:

- `/share/minitel-ha/archives/` — drop your `.vdt` Videotex pages here
- `/share/minitel-ha/config.yaml` — discovered devices and sensors

## Entity discovery

From a terminal on the HA host:

```bash
docker exec addon_minitel_ha python3 /app/discover.py
```

This writes directly to `/share/minitel-ha/config.yaml` (not
`/app/config.yaml`, which is regenerated on every start). **Restart the
add-on** afterwards for new devices to appear.

The merge is non-destructive: your customizations (`name`, `area`,
`visible`) are preserved on every re-discovery.
