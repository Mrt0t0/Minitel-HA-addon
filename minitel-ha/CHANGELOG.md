What's new in v1.1

Area 	Improvement
Installation Official Home Assistant add-on — install in a few clicks, no command line needed
Performance Single GET /api/states call instead of one per entity (51 requests → 1) + 2 s cache
API /api/archives/list and /api/archives/vdt/{name} routes (the browser .vdt reader could not work without them)
Modes AI Assistant, Archives and general Help now available in the browser and on the Minitel
Videotex 	ESC 0x58/0x59/0x5A/0x5C/0x5D/0x5F sequences now match STUM1B, double-height anchored at the bottom
Robustness 	Empty YAML keys tolerated, clean shutdown, sessions and timers closed
Security 	Directory-traversal protection on /api/archives/vdt/
