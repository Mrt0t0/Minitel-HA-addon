# Minitel-HA Add-on — 3615 MAISON

**Language / Langue:** [🇫🇷 Français](#français) | [🇬🇧 English](#english)

Add-on Home Assistant pour **Minitel-HA**.  
Home Assistant add-on for **Minitel-HA**.

> **Documentation complète / Full documentation**  
> Le code source principal, les explications détaillées, l’architecture, le mode Docker standalone et les captures sont disponibles ici :  
> The main source code, detailed documentation, architecture, standalone Docker mode, and screenshots are available here:  
> **https://github.com/Mrt0t0/Minitel-HA**

---

## Français

Ce dépôt contient uniquement le **repository d’add-on Home Assistant** pour installer **Minitel-HA** depuis la boutique des modules complémentaires.

Pour la documentation complète du projet, lire le dépôt principal :  
**https://github.com/Mrt0t0/Minitel-HA**

### Installation

1. Ouvrir **Home Assistant**
2. Aller dans **Paramètres → Modules complémentaires**
3. Ouvrir la **Boutique des modules complémentaires**
4. Cliquer sur le menu **⋮**
5. Choisir **Repositories**
6. Ajouter l’URL de ce dépôt :

```text
https://github.com/Mrt0t0/Minitel-HA-addon
```

7. Rechercher **Minitel-HA**
8. Cliquer sur **Installer**

### Configuration

Exemple de configuration :

```yaml
ha_url: "http://homeassistant.local:8123"
ha_token: "VOTRE_TOKEN_ICI"
splash_seconds: 7
auto_rotate: 30
language: "fr"
```

### Accès

- Interface navigateur : `http://IP_DE_HOME_ASSISTANT:8080`
- Accès Minitel / WebSocket : `ws://IP_DE_HOME_ASSISTANT:3615`

### Documentation complète

Pour tout le reste, consulter le dépôt principal :

- Présentation du projet
- Architecture
- Déploiement Docker standalone
- Configuration avancée
- Découverte automatique des entités
- Connexion Minitel physique via ESP32 / Iodeo / Minimit
- Pages Vidéotex `.vdt`

**https://github.com/Mrt0t0/Minitel-HA**

---

## English

This repository only contains the **Home Assistant add-on repository** used to install **Minitel-HA** from the Add-on Store.

For the full project documentation, please read the main repository:  
**https://github.com/Mrt0t0/Minitel-HA**

### Installation

1. Open **Home Assistant**
2. Go to **Settings → Add-ons**
3. Open the **Add-on Store**
4. Click the **⋮** menu
5. Choose **Repositories**
6. Add this repository URL:

```text
https://github.com/Mrt0t0/Minitel-HA-addon
```

7. Search for **Minitel-HA**
8. Click **Install**

### Configuration

Example configuration:

```yaml
ha_url: "http://homeassistant.local:8123"
ha_token: "YOUR_TOKEN_HERE"
splash_seconds: 7
auto_rotate: 30
language: "en"
```

### Access

- Browser interface: `http://HOME_ASSISTANT_IP:8080`
- Minitel / WebSocket access: `ws://HOME_ASSISTANT_IP:3615`

### Full documentation

For everything else, see the main repository:

- Project overview
- Architecture
- Standalone Docker deployment
- Advanced configuration
- Entity auto-discovery
- Physical Minitel connection through ESP32 / Iodeo / Minimit
- Videotex `.vdt` pages

**https://github.com/Mrt0t0/Minitel-HA**

---

## Links

- Main project: **https://github.com/Mrt0t0/Minitel-HA**
- Add-on repository: **https://github.com/Mrt0t0/Minitel-HA-addon**
