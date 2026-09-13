# Goal §7 用户验收 — 一页清单

**用途：** 本机 Godot 手感确认（**唯一**可关闭 Goal 的门）。  
**引擎入口：** 世界总览顶栏 **「§7验收」** → `scenes/qa/user_qa_checklist.tscn`  
**权威表：** [`GOAL_INTERACT_COMPLETE.md`](GOAL_INTERACT_COMPLETE.md) §7  

勾选保存在 `user://goal_user_qa.cfg`，**不会**自动把 Goal 标 complete。全部通过后请在 Cursor 回复：**§7 已勾**。

## 最短路径（建议顺序）

| # | 项 | 跳转后看什么 |
| --- | --- | --- |
| 1 | 广场 | C58 短帧；C59/C60；K 姿态；户外「互动」 |
| 2 | 市集 | 木棚摊；进后台/夜市可返回 |
| 3 | 河/湖 | 浮漂+水环；渔笼下放约 6s 可收 |
| 4 | 瀑布 | 水体循环动画 |
| 5 | 深林 | C62 树洞密道可进 |
| 6 | C01 | 衣柜开合；↑二楼 |
| 7 | C02 / C06 / C43 | 开盖或进出正常 |
| 8 | Wave D/E 抽样 | 后台或二楼进退 |

## Agent 侧（已绿，不代替本表）

- 全套 `tools/qa_*.py` GREEN（本回合复跑）  
- Wave D/E idle + portal enter MCP  
- Genre/Canon/Style PASS_WITH_NOTES  

## 禁止

- 禁止用 Agent MCP 勾选代替手感  
- 禁止未跑完最短路径就声称 Goal complete  
