# What's new in v1.2.0

- **No token required**
  `ha_token` is now optional: the add-on talks to Home Assistant through the
  Supervisor (`homeassistant_api`). An existing token keeps working.

- **More settings in `/share/minitel-ha/config.yaml`**
  `scenes`, `scripts`, `quick_off`, `area_order` and `meteo` sensors are now
  read from it on every start. An empty `weather_entity` no longer causes errors.

- **Minitel fixes**
  - Letter + ENVOI in the menu always opened the Assistant (the ENVOI code was
    read as the letter A); SUITE in Weather opened Help.
  - The number on screen now always matches the toggled device.
  - Accents are sent with the Minitel G2 set: assistant answers are readable,
    and accents typed on the keyboard reach Home Assistant.
  - The clock is refreshed in place instead of being appended to the line.
  - Archives: digit selection works from page 2 on.

- **Browser fixes**
  `*` (all off) and `0` (journal) work; `0` used to toggle a device from the
  previous page. The WebSocket also works behind HTTPS / a reverse proxy.

# What’s new in v1.1

- **Official Home Assistant add-on**
  Install in just a few clicks — no command line required.

- **Faster Home Assistant data loading**
  Replaced one API request per entity with a single `GET /api/states` call  
  (**51 requests → 1**), with a 2-second cache.

- **New archive API**
  - `GET /api/archives/list`
  - `GET /api/archives/vdt/{name}`

  These endpoints enable the in-browser `.vdt` archive reader.

- **New available modes**
  **AI Assistant**, **Archives**, and **Help** are now available both in the browser interface and directly on the Minitel.

- **Improved Videotex compatibility**
  `ESC 0x58`, `0x59`, `0x5A`, `0x5C`, `0x5D`, and `0x5F` sequences now match **STUM1B** behavior.  
  Double-height text is correctly anchored to the bottom of its display area.

- **More robust operation**
  Empty YAML keys are tolerated, and shutdown now cleanly closes active sessions and timers.

- **Security hardening**
  Added directory-traversal protection for `/api/archives/vdt/`.
