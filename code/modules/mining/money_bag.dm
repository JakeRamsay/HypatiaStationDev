/*****************************Money bag********************************/

/obj/item/weapon/moneybag
	icon = 'icons/obj/storage.dmi'
	name = "Money bag"
	icon_state = "moneybag"
	flags = CONDUCT
	force = 10.0
	throwforce = 2.0
	w_class = 4.0

/obj/item/weapon/moneybag/attack_hand(user as mob)
	var/amt_gold = 0
	var/amt_silver = 0
	var/amt_diamond = 0
	var/amt_iron = 0
	var/amt_phoron = 0
	var/amt_uranium = 0
	var/amt_clown = 0

	for (var/obj/item/weapon/coin/C in contents)
		if (istype(C,/obj/item/weapon/coin/diamond))
			amt_diamond++;
		if (istype(C,/obj/item/weapon/coin/phoron))
			amt_phoron++;
		if (istype(C,/obj/item/weapon/coin/iron))
			amt_iron++;
		if (istype(C,/obj/item/weapon/coin/silver))
			amt_silver++;
		if (istype(C,/obj/item/weapon/coin/gold))
			amt_gold++;
		if (istype(C,/obj/item/weapon/coin/uranium))
			amt_uranium++;
		if (istype(C,/obj/item/weapon/coin/clown))
			amt_clown++;

	var/dat = text("<b>The contents of the moneybag reveal...</b><br>")
	if (amt_gold)
		dat += text("Gold coins: [amt_gold] <A href='?src=\ref[src];remove=gold'>Remove one</A><br>")
	if (amt_silver)
		dat += text("Silver coins: [amt_silver] <A href='?src=\ref[src];remove=silver'>Remove one</A><br>")
	if (amt_iron)
		dat += text("Metal coins: [amt_iron] <A href='?src=\ref[src];remove=iron'>Remove one</A><br>")
	if (amt_diamond)
		dat += text("Diamond coins: [amt_diamond] <A href='?src=\ref[src];remove=diamond'>Remove one</A><br>")
	if (amt_phoron)
		dat += text("Phoron coins: [amt_phoron] <A href='?src=\ref[src];remove=phoron'>Remove one</A><br>")
	if (amt_uranium)
		dat += text("Uranium coins: [amt_uranium] <A href='?src=\ref[src];remove=uranium'>Remove one</A><br>")
	if (amt_clown)
		dat += text("Bananium coins: [amt_clown] <A href='?src=\ref[src];remove=clown'>Remove one</A><br>")
/*
	var/credits=0
	var/list/ore=list()
	for(var/oredata in typesof(/datum/material) - /datum/material)
		var/datum/material/ore_datum = new oredata
		ore[ore_datum.id]=ore_datum

	for (var/obj/item/weapon/coin/C in contents)
		if (istype(C,/obj/item/weapon/coin))
			var/datum/material/ore_info=ore[C.material]
			ore_info.stored++
			ore[C.material]=ore_info
			credits += C.credits

	var/dat = "<b>The contents of the moneybag reveal...</b><ul>"
	for(var/ore_id in ore)
		var/datum/material/ore_info=ore[ore_id]
		if(ore_info.stored)
			dat += "<li>[ore_info.processed_name] coins: [ore_info.stored] <A href='?src=\ref[src];remove=[ore_id]'>Remove one</A></li>"
	dat += "</ul><b>Total haul:</b> $[credits]"
*/
	user << browse("[dat]", "window=moneybag")

/obj/item/weapon/moneybag/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	..()
	if (istype(W, /obj/item/weapon/coin))
		var/obj/item/weapon/coin/C = W
		user << "\blue You add the [C.name] into the bag."
		usr.drop_item()
		contents += C
	if (istype(W, /obj/item/weapon/moneybag))
		var/obj/item/weapon/moneybag/C = W
		for (var/obj/O in C.contents)
			contents += O;
		user << "\blue You empty the [C.name] into the bag."
	return

/obj/item/weapon/moneybag/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(href_list["remove"])
		var/obj/item/weapon/coin/COIN
		switch(href_list["remove"])
			if("gold")
				COIN = locate(/obj/item/weapon/coin/gold,src.contents)
			if("silver")
				COIN = locate(/obj/item/weapon/coin/silver,src.contents)
			if("iron")
				COIN = locate(/obj/item/weapon/coin/iron,src.contents)
			if("diamond")
				COIN = locate(/obj/item/weapon/coin/diamond,src.contents)
			if("phoron")
				COIN = locate(/obj/item/weapon/coin/phoron,src.contents)
			if("uranium")
				COIN = locate(/obj/item/weapon/coin/uranium,src.contents)
			if("clown")
				COIN = locate(/obj/item/weapon/coin/clown,src.contents)
		if(!COIN)
			return
		COIN.loc = src.loc
	return



/obj/item/weapon/moneybag/vault

/obj/item/weapon/moneybag/vault/New()
	..()
	new /obj/item/weapon/coin/silver(src)
	new /obj/item/weapon/coin/silver(src)
	new /obj/item/weapon/coin/silver(src)
	new /obj/item/weapon/coin/silver(src)
	new /obj/item/weapon/coin/gold(src)
	new /obj/item/weapon/coin/gold(src)