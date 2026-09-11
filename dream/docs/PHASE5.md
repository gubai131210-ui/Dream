# Dream Phase 5 — Interior & special areas

**Status:** IN PROGRESS — Wave A **living / shop / farm package DONE** (C01–C04 wired)  
**Depends on:** Outdoor A-class scenes shell ([`PHASE4B.md`](PHASE4B.md) A05–A07, A12–A15 DONE), Phase 4 exit, [`INTERIOR_LIBRARY.md`](INTERIOR_LIBRARY.md), [`ASSET_TAXONOMY.md`](ASSET_TAXONOMY.md), `BUILDING_PLACEMENT.md`, `NPC_ANIM.md`, [`INTERIOR_FOUNDATION.md`](INTERIOR_FOUNDATION.md)

Phase 5 打开世界 **第二/三层**：可进入室内、地下入口、钓鱼最小闭环、昼夜天气壳。  
**不**一次实现 C01–C62 全表。

### Current Wave A checkpoint

| Package | Status | Notes |
| --- | --- | --- |
| Systems-Interior | DONE | `InteriorProfiles` + profile-driven `InteriorCraft` + `InteriorRoomController`; `tools/gen_interior_scenes.py` |
| Home C01+C02 | DONE | 主角宅 + 老人/农家/商贾/铁匠宅；住宅区南排门户 |
| FarmBuild C03 | DONE | 谷仓 + 鸡舍；农场住宅区门户 |
| Shop C04 | DONE | 杂货/铁匠铺/酒馆；商业街门户 |
| Stall-C05 … Env-H | **Wave A2 IN PROGRESS** | 并行开余下包；**延期** C01–C04 室内抛光。见 [`PHASE5_WAVE_A2.md`](PHASE5_WAVE_A2.md) |

- Foundation: 32px floor / wall / door / window / rug — see [`INTERIOR_FOUNDATION.md`](INTERIOR_FOUNDATION.md).
- Furniture: outdoor wood props @ scale **0.55**; warm light = local `PointLight2D` (not full-room orange).
- Silhouettes: home (bed + living) ≠ shop (counter aisle) ≠ barn/coop (stalls / nests).

## Start gate

全部满足才把 Status 改为 `IN PROGRESS`：

1. 约定的室外壳层场景可从 Hub 进入且无缺 `.tscn`  
2. `INTERIOR_LIBRARY.md` / `ASSET_TAXONOMY.md` 已锁定  
3. 用户确认启动 Wave A  

## Wave A — 优先 10（多 agent）

| Agent | Owns | C IDs | Must deliver |
| --- | --- | --- | --- |
| Systems-Interior | `InteriorCraft` 或 AreaCraft 房间 API、`SceneRouter` 室内 path 约定 | — | 进出 portal 标准、房间矩形 |
| Home-C01C02 | 主角宅 + ≥4 村民模板 | C01, C02 | 可进入；升级档数据钩子；禁止单模板 |
| Shop-C04 | 杂货/铁匠/酒馆 | C04 | 三店可进可出 |
| FarmBuild-C03 | 谷仓 + 鸡舍 | C03 | 两内部 |
| Stall-C05 | 市集摊位状态机 | C05 | **DONE** — 6 态同槽位（A10 可演示） |
| Fish-E | 钓鱼地点+动作+2 竿 | C18–C22 | 最小可钓闭环 |
| Mine-C17 | 矿洞入口层 | C17 | 可进入一层 |
| Well-C14C15 | 井底 + 一地下室 | C14, C15 | 井/梯返回 |
| Lighthouse-C12 | 灯塔三层 | C12 | **DONE** — 高塔三簇 + A14 门 portal；见 [`LIGHTHOUSE_C12.md`](./LIGHTHOUSE_C12.md) |
| ForestSecret-C26C27 | 瀑后洞 + 林隐藏点 | C26, C27 | 依赖 A05/A07 |
| Env-H | 夜间+≥3 天气 | C56–C57 / H | 至少一室外场景可切换 |
| Hub-QA | 接线与复查 | — | TopBar 不堆弹层；checklist |

并行时 **文件所有权互斥**；Systems 先合入再开各 Level。

## Out of scope (this phase)

C06–C11 全套公服、C16 全洞穴族、C23 潜水、C31 下水道、C36 全列车、C40–C45 文旅建筑、完整 C55 四季节日美术 — 列入后续 Wave。

## 禁止偷懒

- 禁止未过 Start gate 就开工  
- 禁止门只有 InfoPanel、无室内场景  
- 禁止村民室内单模板  
- 禁止摊位单态「永远营业」  
- 禁止井/瀑/洞有入口无 C 编号场景  
- 禁止室内无返回  
- 禁止节日/夜市整盘新大地图（默认复用广场+装饰层）  
- 禁止 UI 一个「更多」弹层塞全部室内入口  
- 禁止复制室外 assembler 改名交差  
- 禁止室内用棋盘格/平色块地板或整屋橙色洗色冒充温馨（必须先过 `INTERIOR_FOUNDATION.md`）  
- 禁止家/店/仓同一轮廓（须不同 room 尺寸与家具分区）  
- 禁止 `barrel_0` 当通用立桶（仅酒馆酒桶等特例）  
- 禁止未做 C01–C04 进出 QA 就开 Stall/Fish/Mine  

## Acceptance (Wave A)

1. 优先 10 包均可从对应室外进入并返回  
2. C05 可演示 ≥3 种摊位状态切换  
3. 钓鱼最小闭环可在 ≥2 地点钓到占位鱼  
4. 夜间或天气至少一种覆盖可切换  
5. 用户本地 Godot 测（中文路径）  
6. Commit；有 remote 则 push  

**Partial acceptance (this checkpoint):** C01–C04 enter/exit + foundation profiles — **met**. Item 2 (C05 ≥3 stall states) — **met**. Items 3–4 still open.

## Related

- [`INTERIOR_LIBRARY.md`](INTERIOR_LIBRARY.md)  
- [`INTERIOR_FOUNDATION.md`](INTERIOR_FOUNDATION.md)  
- [`ASSET_TAXONOMY.md`](ASSET_TAXONOMY.md)  
- [`PHASE4.md`](PHASE4.md)  
