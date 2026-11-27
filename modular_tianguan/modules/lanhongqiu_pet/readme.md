https://github.com/TianguanStation/Tianguan13/pull/29

## 蓝红球：宠物、召唤信标与配装条目

Module ID: `LANHONGQIU_PET`

### Description:

从**天关旧库 TianGuan13**（Nova 系的 `modular_z121/code/modules/mob/lanhongqiu.dm`）移植过来的玩家宠物内容，整包收进本模块（代码 + 图标），并保留原有行为：

- `/mob/living/basic/pet/lanhongqiu`：蓝红球宠物本体（可被抱起、带一个冲刺闪避动作、能捡天武剑；**抱进宠物箱后可戴在头上**，并会像其他宠物一样**自己趴下休息**）；
- `/obj/item/mob_holder/pet/donator/lanhongqiu`：手持宠物箱；
- `/obj/item/summon_beacon/donatepet/lanhongqiu`：「蓝红球召唤信标」，选中后右键地面召唤宠物；
- `/obj/item/skysword` 天武剑 + `/datum/market_item/misc/skysword`（黑市条目）；
- `/obj/item/lanhongqiucore`：屠宰产物；
- 配装条目 `/datum/loadout_item/inhand/pet/lanhongqiu`（inhand 页签「蓝红球召唤信标」）。

**与旧库的行为差异**：配装条目的 `ckeywhitelist` 由「只有 lanhongqiu」改为 **lanhongqiu + Lv19874900**。

⚠️ 本模块引入一个通用机制：`/datum/loadout_item/private_ckey_lock`。原因是本仓库的 `sponsor_loadout_items` 模块在 `/datum/loadout_item/New()` 里会把**任何**带 `ckeywhitelist` 的条目当成「上游捐赠者残留」清空白名单；而蓝红球召唤信标的白名单是真实私人限定。标记 `private_ckey_lock = TRUE` 的条目会被赞助者解锁跳过，白名单原样保留。

### TG Proc/File Changes:

- `modular_tianguan/modules/sponsor_loadout_items/code/sponsor_loadout_items.dm`：给 `/datum/loadout_item` 增加 `private_ckey_lock`，并在 `New()` 里跳过带该标记的条目（本仓库自己的模块文件）
- `code/modules/unit_tests/~tianguan/sponsor_loadout.dm`：全仓「不得残留 ckeywhitelist」的检查放行 `private_ckey_lock` 条目，并新增断言（信标条目存在、白名单含 lanhongqiu 与 lv19874900、未被 `donator_only` 覆盖）
- `tgstation.dme`：新增本模块 include（天关块尾部，无注释）

**新增图标**：`pets_head.dmi`（戴头 4 方向，state 名与宠物 `icon_state` 同名，四种形态各一份以避免抱着切形态变空白）；`pets.dmi` 追加 `lanhongqiu_rest`（趴下，1 方向）。

### Modular Overrides:

- N/A（本模块只新增类型，不覆盖既有 proc）

### Defines:

- 模块文件内 `LANHONGQIU_ICON` / `LANHONGQIU_HELD_LH` / `LANHONGQIU_HELD_RH` / `LANHONGQIU_HEAD_ICON`（图标路径）与 `LANHONGQIU_OWNER_CKEYS`（可领信标的 ckey 列表），文件末尾全部 `#undef`

### Included files that are not contained in this module:

- `code/modules/unit_tests/~tianguan/sponsor_loadout.dm`：单测必须放在 `code/modules/unit_tests/` 下（`_unit_tests.dm` 末尾有 `#undef TEST_ASSERT*`，只能在该文件作用域 include），所以断言写进该文件而不是模块里。
- `modular_tianguan/modules/sponsor_loadout_items/code/sponsor_loadout_items.dm`：`private_ckey_lock` 的定义与赞助者解锁的跳过逻辑放在该模块（它是解锁策略的归属地），避免在核心 loadout 文件里加变量。

### Credits:

- 宠物、信标、天武剑与配装条目：天关旧库 TianGuan13（原作者保留）
- 移植到本仓库 + `Lv19874900` 白名单 + `private_ckey_lock` 机制：mohu19
