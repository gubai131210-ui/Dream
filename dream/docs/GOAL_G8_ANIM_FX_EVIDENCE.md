# Goal evidence — G8_ANIM_FX

**Runner:** `res://tools/g8_anim_fx_smoke.gd`
**Result:** PASS (exit=0)

## Log excerpt

```
G8_ANIM_FX: start
G8_ANIM_FX: work_pose frames=4
G8_ANIM_FX: shake_tree leaf FX ok
G8_ANIM_FX: PASS
```

Also fixed `NpcRoutineDemo` WorkPoseCue / demo actor rename-before-`queue_free` so K-cycle can respawn pose sheets without name collision.

User Godot QA still required for visual fidelity.
