#!/usr/bin/env python3
from pathlib import Path

p = Path(__file__).resolve().parents[1] / "scripts" / "interiors" / "interior_profiles.gd"
t = p.read_text(encoding="utf-8")
t2 = t.replace(
    'const P_LAMP0 := DIR_OUTDOOR_PROP + "/lamp_0.png"\n'
    'const P_LAMP1 := DIR_OUTDOOR_PROP + "/lamp_1.png"\n',
    'const P_LAMP_INDOOR := DIR_INTERIOR_PROP + "/lamp_indoor_00.png"\n',
)
if t2 == t:
    # maybe already partially edited
    if "P_LAMP_INDOOR" not in t and "P_LAMP0" in t:
        raise SystemExit("lamp const block not found")
t2 = t2.replace("P_LAMP0", "P_LAMP_INDOOR").replace("P_LAMP1", "P_LAMP_INDOOR")
# ensure rocking block still has lamp if we only had replace of usages
if "P_LAMP_INDOOR :=" not in t2:
    t2 = t2.replace(
        'const P_ROCKING := DIR_INTERIOR_PROP + "/rocking_00.png"\n',
        'const P_ROCKING := DIR_INTERIOR_PROP + "/rocking_00.png"\n'
        'const P_LAMP_INDOOR := DIR_INTERIOR_PROP + "/lamp_indoor_00.png"\n',
    )
p.write_text(t2, encoding="utf-8")
print("lamps", t2.count("P_LAMP_INDOOR"))
print("utf8", "ok" if "壁灯" in t2 else "BAD")
