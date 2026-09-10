# Dream Phase 5 — Interior & special areas (draft)

**Status:** DRAFT — **do not start implementation** until outdoor map shell is DONE  
**Depends on:** Outdoor A-class scenes shell (remaining A05–A07, A12–A15 as scoped), Phase 4 exit, [`INTERIOR_LIBRARY.md`](INTERIOR_LIBRARY.md), [`ASSET_TAXONOMY.md`](ASSET_TAXONOMY.md), `BUILDING_PLACEMENT.md`, `NPC_ANIM.md`

Phase 5 打开世界 **第二/三层**：可进入室内、地下入口、钓鱼最小闭环、昼夜天气壳。  
**不**一次实现 C01–C62 全表。

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
| Stall-C05 | 市集摊位状态机 | C05 | 6 态同槽位 |
| Fish-E | 钓鱼地点+动作+2 竿 | C18–C22 | 最小可钓闭环 |
| Mine-C17 | 矿洞入口层 | C17 | 可进入一层 |
| Well-C14C15 | 井底 + 一地下室 | C14, C15 | 井/梯返回 |
| Lighthouse-C12 | 灯塔三层 | C12 | 依赖 A14 室外 |
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

## Acceptance (Wave A)

1. 优先 10 包均可从对应室外进入并返回  
2. C05 可演示 ≥3 种摊位状态切换  
3. 钓鱼最小闭环可在 ≥2 地点钓到占位鱼  
4. 夜间或天气至少一种覆盖可切换  
5. 用户本地 Godot 测（中文路径）  
6. Commit；有 remote 则 push  

## Related

- [`INTERIOR_LIBRARY.md`](INTERIOR_LIBRARY.md)  
- [`ASSET_TAXONOMY.md`](ASSET_TAXONOMY.md)  
- [`PHASE4.md`](PHASE4.md)  
