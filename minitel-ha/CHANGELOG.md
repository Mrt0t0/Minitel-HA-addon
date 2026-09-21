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
