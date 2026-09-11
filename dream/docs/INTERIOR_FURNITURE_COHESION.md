# Interior furniture cohesion (桌椅成套)

**Status:** SHIPPED v1 — cozy dining / tea / bar-stool family installed  
**Date:** 2026-09-11  
**Problem:** 单件资产各自合格，但桌/凳/吧台像不同游戏拼贴（木色、腿粗、透视、描边不一致）。  
**Related:** [`INTERIOR_COMPOSITION.md`](./INTERIOR_COMPOSITION.md), [`INTERIOR_ASSET_AUDIT.md`](./INTERIOR_ASSET_AUDIT.md)

## User intent (locked)

即使来自两套资源，也必须 **肉眼看不出拼接**：同一木作工坊、同一光向、同一比例语言。现实里也不会把「厚重四腿饭桌」配「完全另一套细腿装饰凳」。

## Why mismatch feels wrong

| Clash | Pre-fix Dream |
| --- | --- |
| 木色色温不同 | 饭桌冷深褐 vs 凳橙亮 |
| 腿截面语言不同 | 桌腿方粗 vs 凳腿圆细 |
| 透视/抗锯齿档次不同 | 圆桌「光滑」vs 饭桌「硬像素」 |
| 座高 vs 桌沿违和 | 用同一 scale 硬凑高度 |
| 风格语义冲突 | 酒吧黄铜细节硬配农家粗木凳 |

行业做法：成套包装（同一作者、同 3/4、同 palette）。

## Matching rules (Dream lock)

1. **Palette:** 共用暖褐木作色阶  
2. **Light:** 左上受光  
3. **Outline:** 同 1px 深轮廓  
4. **Projection:** 统一 3/4  
5. **Legs:** 饭桌↔方腿矮凳；圆桌↔柱座矮凳；吧台↔高四腿凳  
6. **Height:** 从同 atlas **按比例**切片（禁止全部强制 64h）  
7. **Author as set:** 同 sheet 一次生成再切片  

## Families shipped

| Family | Members | Profiles |
| --- | --- | --- |
| `cozy_dining` | `table_dining_00` + `stool_00` | c01 hearth, farmer dining, smith wait, tavern hearth |
| `cozy_tea` | `table_round_00` + `stool_tea_00` | elder tea, tavern party_a/b |
| `tavern_bar` | `stool_bar_00`（吧台 `bar_00` 仍为旧件，木色接近） | c04 bar cluster |

## Install

- Atlas: `assets/sprites/interior/props/_source_atlases/furniture_family_cozy.png`
- Tool: `tools/install_furniture_family_cohesion.py`
- QA row: `assets/sprites/interior/props/_diag_furniture_cohesion_row.png`
- Pre-fix backups: `props/_misnamed_archive/pre_cohesion*.png`

## Residual (next)

- `bar_00` 黄铜脚踏 / 龙头 vs 纯木家族仍有档次差 → 下一轮同 sheet 重做吧台  
- `rocking_00` 与 cozy_tea 仍非同 sheet → 老人宅摇椅后续成套  

## 禁止偷懒

- 禁止只缩放/调色假装成套  
- 禁止饭桌自带椅子再额外摆独立凳  
- 禁止圆桌用一套风格、长桌用另一套  
- 禁止「凳好看就留」不顾桌沿高度  
- 禁止全部 normalize 到同一高度再假扮比例  
- 禁止调研文档写完不换运行时 PNG  
