# Goal §7 用户验收 — 一页清单

**用途：** 本机 Godot 手感确认（**唯一**可关闭 Goal 的门）。  
**引擎入口：** 世界总览顶栏 **「§7验收」** → `scenes/qa/user_qa_checklist.tscn`  
**权威表：** [`GOAL_INTERACT_COMPLETE.md`](GOAL_INTERACT_COMPLETE.md) §7  

勾选保存在 `user://goal_user_qa.cfg`，**不会**自动把 Goal 标 complete。全部通过后点清单 **「复制「§7 已勾」」** 或在 Cursor 回复：**§7 已勾**。

从清单「跳转」进入场景后，右上角会出现 **「回§7清单」**，测完可立即返回继续勾选。

## 引擎清单（21 项，对齐 §7 户外全表 + 室内抽样）

| 组 | 跳转项 |
| --- | --- |
| 户外全表 | 广场 / 市集 / 农田 / 住宅 / 农场住宅 / 林口 / 深林C62 / 河 / 湖 / 瀑布 / 灯塔 / 坡田 / 车站 / 湖屋 |
| 室内抽样 | C01 / C02 / C06 / C40 / C43 / Wave D 后台 / Wave E 二楼 |

## Agent 侧（已绿，不代替本表）

- 全套 `tools/qa_*.py` GREEN  
- Agent walkthrough 含灯塔/坡田/湖屋 idle MCP（`g8_walkthrough_*`）  
- Genre/Canon/Style PASS_WITH_NOTES  

## 禁止

- 禁止用 Agent MCP 勾选代替手感  
- 禁止未跑完清单就声称 Goal complete  
