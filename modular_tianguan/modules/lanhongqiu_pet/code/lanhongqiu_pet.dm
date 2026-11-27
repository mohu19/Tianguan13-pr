// LANHONGQIU_PET - 蓝红球宠物与「蓝红球召唤信标」
//
// 移植自天关旧库（TianGuan13 的 modular_z121/code/modules/mob/lanhongqiu.dm）：宠物本体、
// 手持宠物箱、召唤信标、天武剑、蓝红球的核心，以及「蓝红球召唤信标」的配装条目。
//
// 与旧库的差异：
//   1. 配装条目的 ckey 白名单由「仅 lanhongqiu」改为 lanhongqiu + Lv19874900；
//   2. 该白名单是真实私人限定，用 private_ckey_lock 标记，避免 sponsor_loadout_items 的
//      「赞助者解锁」在 /datum/loadout_item/New() 里把它清空。

#define LANHONGQIU_ICON 'modular_tianguan/modules/lanhongqiu_pet/icons/pets.dmi'
#define LANHONGQIU_HELD_LH 'modular_tianguan/modules/lanhongqiu_pet/icons/pets_held_lh.dmi'
#define LANHONGQIU_HELD_RH 'modular_tianguan/modules/lanhongqiu_pet/icons/pets_held_rh.dmi'
/// 戴在头上时用的图集（state 名与宠物 icon_state 同名，4 方向）
#define LANHONGQIU_HEAD_ICON 'modular_tianguan/modules/lanhongqiu_pet/icons/pets_head.dmi'

/// 可以领「蓝红球召唤信标」的玩家（New() 里会统一 ckey() 归一化，大小写无所谓）
#define LANHONGQIU_OWNER_CKEYS list("lanhongqiu", "Lv19874900")

/datum/loadout_item/inhand/pet/lanhongqiu
	name = "蓝红球召唤信标"
	item_path = /obj/item/summon_beacon/donatepet/lanhongqiu
	ckeywhitelist = LANHONGQIU_OWNER_CKEYS
	/// 真实私人限定：不要让赞助者解锁清空白名单
	private_ckey_lock = TRUE

/obj/item/lanhongqiucore
	name = "蓝红球的核心"
	desc = "你怎么敢的！这可不是在杀史莱姆，你杀死了一个和你一样有思想感情的生物！"
	icon = LANHONGQIU_ICON
	icon_state = "lanhongqiu_core"

/mob/living/basic/pet/lanhongqiu
	name = "蓝红球"
	desc = "克罗托生物，也许别人会认为是史莱姆的变种，实际是他们已经在当地建立了一个庞大的世界国家。别惹他！这是世界共和国的公民！"
	gender = MALE
	icon = LANHONGQIU_ICON
	held_lh = LANHONGQIU_HELD_LH
	held_rh = LANHONGQIU_HELD_RH
	head_icon = LANHONGQIU_HEAD_ICON
	/// 抱进宠物箱后可以戴在头上（/obj/item/mob_holder 的既有机制）
	worn_slot_flags = ITEM_SLOT_HEAD
	icon_state = "lanhongqiu"
	icon_living = "lanhongqiu"
	icon_dead = "lanhongqiu_dead"
	held_state = "lanhongqiu"
	melee_damage_lower = 0
	melee_damage_upper = 0
	pass_flags = PASSTABLE
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	minimum_survivable_temperature = NPC_DEFAULT_MIN_TEMP
	maximum_survivable_temperature = NPC_DEFAULT_MAX_TEMP
	maxHealth = 100
	health = 100
	var/datum/action/cooldown/mob_cooldown/charge/basic_charge/dodgeroll/charge
	var/charge_type = /datum/action/cooldown/mob_cooldown/charge/basic_charge/dodgeroll
	butcher_results = list(/obj/item/lanhongqiucore = 1)
	unsuitable_atmos_damage = 0.5
	mobility_flags = MOBILITY_FLAGS_REST_CAPABLE_DEFAULT
	obj_damage = 0
	var/obj/item/skysword/weapon

/obj/item/mob_holder/pet/donator/lanhongqiu
	name = "蓝红球"
	desc = "克罗托生物，也许别人会认为是史莱姆的变种，实际是他们已经在当地建立了一个庞大的世界国家。别惹他！这是世界共和国的公民！"
	icon = LANHONGQIU_ICON
	icon_state = "lanhongqiu"

	starting_pet = /mob/living/basic/pet/lanhongqiu

/mob/living/basic/pet/lanhongqiu/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/can_be_held)
	charge = new charge_type(src)
	charge.Grant(src)

/datum/action/cooldown/mob_cooldown/charge/basic_charge/dodgeroll
	cooldown_time = 5 SECONDS
	charge_delay = 0.1 SECONDS
	charge_past = 0
	charge_distance = 2
	charge_damage = 0
	destroy_objects = FALSE

/datum/action/cooldown/mob_cooldown/charge/basic_charge/dodgeroll/do_charge(atom/movable/charger, atom/target_atom, delay, past)
	. = ..()
	if(!isliving(charger))
		return
	ADD_TRAIT(charger, TRAIT_UNHITTABLE_BY_PROJECTILES, REF(src))
	charger.SpinAnimation(FLIP_EMOTE_DURATION, 1)
	addtimer(TRAIT_CALLBACK_REMOVE(charger, TRAIT_UNHITTABLE_BY_PROJECTILES, REF(src)), TAUNT_EMOTE_DURATION * 1)

/mob/living/basic/pet/lanhongqiu/UnarmedAttack(atom/A, proximity_flag, list/modifiers)
	. = ..()
	if(!isitem(A))
		return

	if(!weapon && istype(A, /obj/item/skysword))
		visible_message(span_notice("[src] 拿起了 [A]."), span_notice("你拿起了 [A]."))
		weapon = A
		weapon.forceMove(src)
		melee_damage_lower = 18
		melee_damage_upper = 22
		armour_penetration = 0
		wound_bonus = CANT_WOUND
		update_icons()
	else if(!weapon && !istype(A, /obj/item/spear))
		to_chat(src, span_warning("你不会使用[A]！"))

/// 三种形态：死亡（基类） / 趴下休息 / 持天武剑 / 平常
/mob/living/basic/pet/lanhongqiu/update_icon_state()
	. = ..()
	if(stat == DEAD)
		return
	if(resting)
		icon_state = "[icon_living]_rest"
		return
	icon_state = weapon ? "[initial(icon_state)]_sword" : initial(icon_state)

/mob/living/basic/pet/lanhongqiu/update_icons()
	. = ..()
	update_icon_state()

/mob/living/basic/pet/lanhongqiu/update_resting()
	. = ..()
	if(stat != DEAD)
		update_appearance(UPDATE_ICON_STATE)

/// 像其他宠物（poppy / bumbles）一样自己找时机趴下、再自己起来
/mob/living/basic/pet/lanhongqiu/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	. = ..()
	if(client || stat)
		return
	if(!SPT_PROB(0.5, seconds_per_tick))
		return
	if(!resting)
		manual_emote(pick("缩成一团趴了下来。", "伸了个懒腰，趴下休息。", "滚了滚，趴在地上。"))
		set_resting(TRUE)
	else
		manual_emote(pick("晃了晃身体站了起来。", "抖抖身子爬起来。", "抬起头，重新站好。"))
		set_resting(FALSE)

/mob/living/basic/pet/lanhongqiu/death(gibbed)
	if(weapon)
		weapon.forceMove(get_turf(src))
		weapon = null
	update_icons()
	. = ..()

/obj/item/skysword
	name = "天武剑"
	desc = "这是天地文武大将军曾经的武器，剑身黑，泛银光，削铁如泥，千年不锈。祂曾经用这把利剑杀尽王侯，使天下太平。很遗憾，这把剑只能被蓝红球使用，并且由于世界共和国文物保护协议的规定，此剑已被追踪。你最好在文物保护官员和共和国战斗队到来之前联系官方并归还。"
	icon = LANHONGQIU_ICON
	icon_state = "skysword"

/datum/market_item/misc/skysword
	name = "天武剑"
	desc = "这是天地文武大将军曾经的武器，剑身黑，泛银光，削铁如泥，千年不锈。祂曾经用这把利剑杀尽王侯，使天下太平。很遗憾，这把剑只能被蓝红球使用。"
	item = /obj/item/skysword
	price_min = CARGO_CRATE_VALUE * 3
	price_max = CARGO_CRATE_VALUE * 5
	stock_max = 1
	availability_prob = 90

/obj/item/summon_beacon/donatepet/lanhongqiu
	name = "蓝红球召唤信标"
	desc = "召唤宠物！不含零食"
	selectable_atoms = list(/mob/living/basic/pet/lanhongqiu)

#undef LANHONGQIU_OWNER_CKEYS
#undef LANHONGQIU_HELD_RH
#undef LANHONGQIU_HELD_LH
#undef LANHONGQIU_ICON
