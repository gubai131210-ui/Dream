# Asset taxonomy (A–H)

**Status:** LOCKED  
**Date:** 2026-09-10  
**Purpose:** 统一素材/场景编号语言，避免「只有 A 参考图 + B 室外贴图、进门空洞」。  
**Raw inventory:** [`../assets/MANIFEST.md`](../assets/MANIFEST.md)（现有 A/B 文件列表；本文件定义分层语义，不强制立刻重命名全部 raw）

---

## Layers

| 层 | 名称 | 含义 | 现状 |
| --- | --- | --- | --- |
| **A** | World / Scene references | 整体场景参考图、连接总览（A01–A16） | MANIFEST 已映射 |
| **B** | Outdoor Asset Library | 地面/水/树/建筑/道具/NPC 表/特效等室外可切片素材（B01–B15…） | MANIFEST 已映射 |
| **C** | Interior Library | 可进入室内与建筑附属内部 | 目录锁定：[`INTERIOR_LIBRARY.md`](INTERIOR_LIBRARY.md) |
| **D** | Dungeon & Underground | 洞穴分层、矿洞、下水道、井底网络 | 与 C14–C17/C31 交叉；素材包未来独立 |
| **E** | Gameplay Scene Library | 钓鱼/农业加工/商店柜台等玩法专用场景与 UI 锚点 | C18–C22、C38–C39 等 |
| **F** | Event Library | 节日覆盖、剧情专图、特殊列车等 | C33/C55 等 |
| **G** | Interaction Library | 可交互/可破坏/进度障碍/宝箱/密道道具 | C58–C62 |
| **H** | Environment State Library | 昼夜、天气、季节调色与灯效 | C56–C57 |

```text
A 参考构图
B 室外零件
    ↓ 组装
室外区域场景 (Phase 1–4…)
    ↓ 门 / 洞 / 井
C 室内 + D 地下
    ↓
E 玩法 · F 事件 · G 交互 · H 时空状态
```

---

## Path conventions (future)

| 层 | Godot 路径习惯 |
| --- | --- |
| A | `assets/raw/A*.png`, `assets/raw/references/` |
| B | `assets/raw/B*`, `assets/sprites/`, `assets/tilesets/` |
| C | `scenes/interiors/{c_id}/`, `assets/sprites/interior/`（待建） |
| D | `scenes/dungeons/{id}/`（待建） |
| E | `scenes/gameplay/` 或挂在室内节点下 |
| F | `scenes/events/` 或装饰层资源 |
| G | props + `InteractableHotspot` 元数据 |
| H | 调色/粒子/CanvasModulate 资源 |

---

## Rules

1. **先壳后芯：** 未完成约定的室外壳层前，不批量开工 C 全表（见 `INTERIOR_LIBRARY.md` 时机）。  
2. **A 不是场景：** 禁止把 A 参考图整张贴进可玩场景交差。  
3. **B 服务室外 district：** 布局参数见 `AREA_FRAMEWORK.md`。  
4. **C 必须可进出：** 有进入必有返回。  
5. **编号稳定：** 新素材进 MANIFEST 时标注所属层（A–H）与可选 Cxx 交叉引用。

---

## Related

- [`INTERIOR_LIBRARY.md`](INTERIOR_LIBRARY.md)  
- [`PHASE5.md`](PHASE5.md)  
- [`SCALE.md`](SCALE.md) · [`SEAMLESS.md`](SEAMLESS.md)  
