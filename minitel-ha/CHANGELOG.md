## What’s new in v1.1

| Area | Improvement |
|---|---|
| **Installation** | Official Home Assistant add-on — install in a few clicks, with no command line required. |
| **Performance** | Optimized Home Assistant state retrieval: a single `GET /api/states` request replaces one request per entity (**51 requests → 1**), with a 2-second cache. |
| **API** | Added `GET /api/archives/list` and `GET /api/archives/vdt/{name}` endpoints. These routes are required for the in-browser `.vdt` archive reader. |
| **Modes** | **AI Assistant**, **Archives**, and general **Help** are now available both in the browser interface and on the Minitel. |
| **Videotex** | Improved compatibility for `ESC 0x58`, `0x59`, `0x5A`, `0x5C`, `0x5D`, `0x5F` sequences to match **STUM1B** behavior. Double-height text is now correctly anchored at the bottom. |
| **Robustness** | Empty YAML keys are now tolerated. Improved shutdown behavior ensures sessions and timers are closed cleanly. |
| **Security** | Added directory-traversal protection for the `/api/archives/vdt/` endpoint. |
