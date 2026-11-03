# What's new in v1.3.0

- **Real time**
  The add-on subscribes to the Home Assistant WebSocket: state changes show
  up immediately and only the affected lines are redrawn. It falls back to
  polling if the WebSocket is unavailable.

- **Sidebar and access code**
  Minitel-HA opens from the Home Assistant sidebar (ingress). New optional
  `access_code` option for the Minitel and the browser on port 8080:
  3 attempts per connection, IP blocked for 5 minutes after 5 failures.

- **Browser = real Minitel emulator**
  The browser now shows exactly the Minitel pages (row 0, accents, cursor,
  double size), with physical and on-screen keyboards. `.vdt` pages can be
  uploaded from the emulator.

- **New features**
  - Sensors mode (`C`) with a 24h semi-graphic chart.
  - Covers, thermostats, media players, locks and fans; `SUITE` / `RETOUR`
    adjust the selected device (brightness, position, setpoint, volume).
  - Alerts on the Minitel row 0 (`alerts` in `/share/minitel-ha/config.yaml`).
  - Confirmation for "all off" (`*`) and for unlocking a lock.
  - The action journal is kept in `/share/minitel-ha/journal.json`.
  - Screens in French or English (`language` option).
  - `display`, `alerts` and `discovery` read from `/share/minitel-ha/config.yaml`.

- **Under the hood**
  One logic shared by the Minitel and the browser, automated tests and CI,
  dependencies pinned in `requirements.txt`, base image 3.23, watchdog,
  option translations. The add-on code is checked against Minitel-HA by CI.

- **Behaviour change**
  In the menu, a letter now opens its mode directly (no `ENVOI` needed), as
  in every other mode.

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
