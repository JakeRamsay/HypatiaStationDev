/obj/item/weapon/grenade/flashbang
	name = "flashbang"
	icon_state = "flashbang"
	item_state = "flashbang"
	icon_override = 'icons/mob/in-hand/tools.dmi'
	origin_tech = "materials=2;combat=1"
	var/banglet = 0

/obj/item/weapon/grenade/flashbang/prime()
	update_mob()
	var/flashbang_turf = get_turf(src)
	if(!flashbang_turf)
		return
	for(var/mob/living/M in hearers(7, flashbang_turf))
		bang(get_turf(M), M)

	for(var/obj/effect/blob/B in hear(8,flashbang_turf))     		//Blob damage here
		var/damage = round(30/(get_dist(B,get_turf(src))+1))
		B.health -= damage
		B.update_icon()
	del(src)

/obj/item/weapon/grenade/flashbang/proc/bang(var/turf/T , var/mob/living/M)
	M.show_message("<span class='warning'>BANG</span>", 2)
	playsound(src.loc, 'sound/effects/bang.ogg', 25, 1)

//Checking for protections
	var/eye_safety = 0
	var/ear_safety = 0
	var/distance = max(1,get_dist(src,T))
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		eye_safety = C.eyecheck()
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			if((H.r_ear && (H.r_ear.flags & EARBANGPROTECT)) || (H.l_ear && (H.l_ear.flags & EARBANGPROTECT)) || (H.head && (H.head.flags & HEADBANGPROTECT)))
				ear_safety++

//Flash
	if(!eye_safety && ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/eyes/E = H.internal_organs_by_name["eyes"]
		flick("e_flash", M.flash)
		if (E) E.damage += rand(1, 3)
		M.Stun(max(10/distance, 3))
		M.Weaken(max(10/distance, 3))
		if (E && E.damage >= E.min_bruised_damage)
			M << "<span class='warning'>Your eyes start to burn badly!</span>"
			if(!banglet && !(istype(src , /obj/item/weapon/grenade/flashbang/clusterbang)))
				if (E.damage >= E.min_broken_damage)
					M << "<span class='warning'>You can't see anything!</span>"

//Bang
	if((src.loc == M) || src.loc == M.loc)//Holding on person or being exactly where lies is significantly more dangerous and voids protection
		M.Stun(10)
		M.Weaken(10)
	if(!ear_safety)
		M.Stun(max(10/distance, 3))
		M.Weaken(max(10/distance, 3))
		M.ear_damage += rand(0, 5)
		M.ear_deaf = max(M.ear_deaf,15)
		if (M.ear_damage >= 15)
			M << "<span class='warning'>Your ears start to ring badly!</span>"
			if(!banglet && !(istype(src , /obj/item/weapon/grenade/flashbang/clusterbang)))
				if(prob(M.ear_damage - 10 + 5))
					M << "<span class='warning'>You can't hear anything!</span>"
					M.disabilities |= DEAF
		else
			if (M.ear_damage >= 5)
				M << "<span class='warning'>Your ears start to ring!</span>"

////////////////////
//Clusterbang
////////////////////
/obj/item/weapon/grenade/flashbang/clusterbang
	desc = "Use of this weapon may constiute a war crime in your area, consult your local captain."
	name = "clusterbang"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "clusterbang"

/obj/item/weapon/grenade/flashbang/clusterbang/prime()
	update_mob()
	var/numspawned = rand(4,8)
	var/again = 0

	for(var/more = numspawned,more > 0,more--)
		if(prob(35))
			again++
			numspawned--

	for(var/loop = numspawned, loop > 0, loop--)
		new /obj/item/weapon/grenade/flashbang/cluster(loc)//Launches flashbangs

	for(var/loop = again ,loop > 0, loop--)
		new /obj/item/weapon/grenade/flashbang/clusterbang/segment(loc)//Creates a 'segment' that launches a few more flashbangs

	playsound(src.loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)

	del(src)


//////////////////////
//Clusterbang segment
//////////////////////
/obj/item/weapon/grenade/flashbang/clusterbang/segment
	desc = "A smaller segment of a clusterbang. Better run."
	name = "clusterbang segment"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "clusterbang_segment"

/obj/item/weapon/grenade/flashbang/clusterbang/segment/New()
	..()
	icon_state = "clusterbang_segment_active"
	active = 1
	walk_away(src,loc,rand(1,4))
	spawn(rand(15,60))
		prime()


/obj/item/weapon/grenade/flashbang/clusterbang/segment/prime()
	update_mob()
	var/numspawned = rand(4,8)

	for(var/loop = numspawned ,loop > 0, loop--)
		new /obj/item/weapon/grenade/flashbang/cluster(loc)

	playsound(src.loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)

	del(src)

////////////////////////////////
//Clusterbang spawned flashbang
////////////////////////////////
/obj/item/weapon/grenade/flashbang/cluster/New()
	..()
	icon_state = "flashbang_active"
	active = 1
	banglet = 1
	walk_away(src,loc,rand(1,3))
	spawn(rand(15,60))
		prime()