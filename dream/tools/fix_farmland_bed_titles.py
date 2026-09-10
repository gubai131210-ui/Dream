#!/usr/bin/env python3
"""Fix farmland crop-bed Chinese titles and ensure UTF-8."""
from pathlib import Path

path = Path(__file__).resolve().parents[1] / "scripts/areas/farmland_assembler.gd"
text = path.read_text(encoding="utf-8")

old = '''\tvar beds: Array[Dictionary] = [
\t\t{"x0": 4, "y0": 4, "x1": 8, "y1": 7, "title": "è¥¿åéº¦ç°", "desc": "çæºæ¸ è¥¿ä¾§å°éº¦ç¦ã", "color": Color(0.78, 0.7, 0.28, 0.92), "rows": 4},
\t\t{"x0": 4, "y0": 11, "x1": 8, "y1": 15, "title": "è¥¿è¬èç¦", "desc": "æ¸ è¥¿ç»¿å¶è¬èã", "color": Color(0.38, 0.68, 0.3, 0.9), "rows": 5},
\t\t{"x0": 4, "y0": 20, "x1": 8, "y1": 24, "title": "è¥¿åèç¦", "desc": "åç«¯å¶èç¦ã", "color": Color(0.42, 0.74, 0.32, 0.9), "rows": 4},
\t\t{"x0": 16, "y0": 4, "x1": 22, "y1": 7, "title": "åéº¦ç°", "desc": "ä¸­å¿æ¢çº½åä¾§éº¦ç°ã", "color": Color(0.82, 0.74, 0.3, 0.92), "rows": 3},
\t\t{"x0": 27, "y0": 4, "x1": 33, "y1": 8, "title": "ä¸åéº¦ç°", "desc": "ä¸ä¾§éé»éº¦ç°ã", "color": Color(0.8, 0.72, 0.26, 0.92), "rows": 4},
\t\t{"x0": 28, "y0": 11, "x1": 33, "y1": 15, "title": "ä¸è¬èç¦", "desc": "è°·ä»ä¸ä¾§èç¦ã", "color": Color(0.35, 0.66, 0.28, 0.9), "rows": 5},
\t\t{"x0": 27, "y0": 20, "x1": 33, "y1": 24, "title": "ä¸åèç¦", "desc": "ä¸åè§è¬èç¦ã", "color": Color(0.48, 0.7, 0.34, 0.9), "rows": 4},
\t\t{"x0": 16, "y0": 20, "x1": 23, "y1": 24, "title": "åéº¦ç°", "desc": "æ¢çº½åä¾§éº¦ç°ã", "color": Color(0.76, 0.68, 0.25, 0.92), "rows": 4},
\t]'''

# Find beds array by markers regardless of current garbled titles
start = text.find("var beds: Array[Dictionary] = [")
end = text.find("]\n\tfor b in beds:", start)
if start < 0 or end < 0:
    raise SystemExit(f"beds block not found start={start} end={end}")

new_block = '''var beds: Array[Dictionary] = [
\t\t{"x0": 4, "y0": 4, "x1": 8, "y1": 7, "title": "西北麦田", "desc": "灌溉渠西侧小麦畦。", "color": Color(0.78, 0.7, 0.28, 0.92), "rows": 4},
\t\t{"x0": 4, "y0": 11, "x1": 8, "y1": 15, "title": "西蔬菜畦", "desc": "渠西绿叶蔬菜。", "color": Color(0.38, 0.68, 0.3, 0.9), "rows": 5},
\t\t{"x0": 4, "y0": 20, "x1": 8, "y1": 24, "title": "西南菜畦", "desc": "南端叶菜畦。", "color": Color(0.42, 0.74, 0.32, 0.9), "rows": 4},
\t\t{"x0": 16, "y0": 4, "x1": 22, "y1": 7, "title": "北麦田", "desc": "中心枢纽北侧麦田。", "color": Color(0.82, 0.74, 0.3, 0.92), "rows": 3},
\t\t{"x0": 27, "y0": 4, "x1": 33, "y1": 8, "title": "东北麦田", "desc": "东侧金黄麦田。", "color": Color(0.8, 0.72, 0.26, 0.92), "rows": 4},
\t\t{"x0": 28, "y0": 11, "x1": 33, "y1": 15, "title": "东蔬菜畦", "desc": "谷仓东侧菜畦。", "color": Color(0.35, 0.66, 0.28, 0.9), "rows": 5},
\t\t{"x0": 27, "y0": 20, "x1": 33, "y1": 24, "title": "东南菜畦", "desc": "东南角蔬菜畦。", "color": Color(0.48, 0.7, 0.34, 0.9), "rows": 4},
\t\t{"x0": 16, "y0": 20, "x1": 23, "y1": 24, "title": "南麦田", "desc": "枢纽南侧麦田。", "color": Color(0.76, 0.68, 0.25, 0.92), "rows": 4},
\t]'''

text = text[:start] + new_block + text[end + 1 :]
path.write_text(text, encoding="utf-8")
print("farmland beds titles fixed")
