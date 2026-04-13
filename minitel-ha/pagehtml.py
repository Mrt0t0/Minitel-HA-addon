from pathlib import Path

_html = ""

def load(port=None):
    global _html
    p = Path(__file__).parent / 'static' / 'index.html'
    _html = p.read_text(encoding='utf-8')

def get():
    return _html
