/datum/admins/Topic(href, href_list)
	..()

	if(usr.client != src.owner || !check_rights(0))
		log_admin("[key_name(usr)] tried to use the admin panel without authorization.")
		message_admins("[usr.key] has attempted to override the admin panel!")
		return

	if(ticker.mode && ticker.mode.check_antagonists_topic(href, href_list))
		check_antagonists()
		return

	if(href_list["makeAntag"])
		switch(href_list["makeAntag"])
			if("1")
				log_admin("[key_name(usr)] has spawned a traitor.")
				if(!src.makeTraitors())
					usr << "\red Unfortunately there weren't enough candidates available."
			if("2")
				log_admin("[key_name(usr)] has spawned a changeling.")
				if(!src.makeChanglings())
					usr << "\red Unfortunately there weren't enough candidates available."
			if("3")
				log_admin("[key_name(usr)] has spawned revolutionaries.")
				if(!src.makeRevs())
					usr << "\red Unfortunately there weren't enough candidates available."
			if("4")
				log_admin("[key_name(usr)] has spawned a cultists.")
				if(!src.makeCult())
					usr << "\red Unfortunately there weren't enough candidates available."
			if("5")
				log_admin("[key_name(usr)] has spawned a malf AI.")
				if(!src.makeMalfAImode())
					usr << "\red Unfortunately there weren't enough candidates available."
			if("6")
				log_admin("[key_name(usr)] has spawned a wizard.")
				if(!src.makeWizard())
					usr << "\red Unfortunately there weren't enough candidates available."
			if("7")
				log_admin("[key_name(usr)] has spawned vampires.")
				if(!src.makeVampires())
					usr << "\red Unfortunately there weren't enough candidates available."
			if("8")
				log_admin("[key_name(usr)] has spawned vox raiders.")
				if(!src.makeVoxRaiders())
					usr << "\red Unfortunately there weren't enough candidates available."

	else if(href_list["dbsearchckey"] || href_list["dbsearchadmin"] || href_list["dbsearchip"] || href_list["dbsearchcid"] || href_list["dbsearchbantype"])
		var/adminckey = href_list["dbsearchadmin"]
		var/playerckey = href_list["dbsearchckey"]
		var/playerip = href_list["dbsearchip"]
		var/playercid = href_list["dbsearchcid"]
		var/dbbantype = text2num(href_list["dbsearchbantype"])
		var/match = 0

		if("dbmatch" in href_list)
			match = 1

		DB_ban_panel(playerckey, adminckey, playerip, playercid, dbbantype, match)
		return

	else if(href_list["dbbanedit"])
		var/banedit = href_list["dbbanedit"]
		var/banid = text2num(href_list["dbbanid"])
		if(!banedit || !banid)
			return

		DB_ban_edit(banid, banedit)
		return

	else if(href_list["dbbanaddtype"])

		var/bantype = text2num(href_list["dbbanaddtype"])
		var/banckey = href_list["dbbanaddckey"]
		var/banip = href_list["dbbanaddip"]
		var/bancid = href_list["dbbanaddcid"]
		var/banduration = text2num(href_list["dbbaddduration"])
		var/banjob = href_list["dbbanaddjob"]
		var/banreason = href_list["dbbanreason"]

		banckey = ckey(banckey)

		switch(bantype)
			if(BANTYPE_PERMA)
				if(!banckey || !banreason)
					usr << "Not enough parameters (Requires ckey and reason)"
					return
				banduration = null
				banjob = null
			if(BANTYPE_TEMP)
				if(!banckey || !banreason || !banduration)
					usr << "Not enough parameters (Requires ckey, reason and duration)"
					return
				banjob = null
			if(BANTYPE_JOB_PERMA)
				if(!banckey || !banreason || !banjob)
					usr << "Not enough parameters (Requires ckey, reason and job)"
					return
				banduration = null
			if(BANTYPE_JOB_TEMP)
				if(!banckey || !banreason || !banjob || !banduration)
					usr << "Not enough parameters (Requires ckey, reason and job)"
					return
			if(BANTYPE_APPEARANCE)
				if(!banckey || !banreason)
					usr << "Not enough parameters (Requires ckey and reason)"
					return
				banduration = null
				banjob = null

		var/mob/playermob

		for(var/mob/M in player_list)
			if(M.ckey == banckey)
				playermob = M
				break


		banreason = "(MANUAL BAN) "+banreason

		if(!playermob)
			if(banip)
				banreason = "[banreason] (CUSTOM IP)"
			if(bancid)
				banreason = "[banreason] (CUSTOM CID)"
		else
			message_admins("Ban process: A mob matching [playermob.ckey] was found at location [playermob.x], [playermob.y], [playermob.z]. Custom ip and computer id fields replaced with the ip and computer id from the located mob")

		DB_ban_record(bantype, playermob, banduration, banreason, banjob, null, banckey, banip, bancid )


	else if(href_list["editrights"])
		if(!check_rights(R_PERMISSIONS))
			message_admins("[key_name_admin(usr)] attempted to edit the admin permissions without sufficient rights.")
			log_admin("[key_name(usr)] attempted to edit the admin permissions without sufficient rights.")
			return

		var/adm_ckey

		var/task = href_list["editrights"]
		if(task == "add")
			var/new_ckey = ckey(input(usr,"New admin's ckey","Admin ckey", null) as text|null)
			if(!new_ckey)	return
			if(new_ckey in admin_datums)
				usr << "<font color='red'>Error: Topic 'editrights': [new_ckey] is already an admin</font>"
				return
			adm_ckey = new_ckey
			task = "rank"
		else if(task != "show")
			adm_ckey = ckey(href_list["ckey"])
			if(!adm_ckey)
				usr << "<font color='red'>Error: Topic 'editrights': No valid ckey</font>"
				return

		var/datum/admins/D = admin_datums[adm_ckey]

		if(task == "remove")
			if(alert("Are you sure you want to remove [adm_ckey]?","Message","Yes","Cancel") == "Yes")
				if(!D)	return
				admin_datums -= adm_ckey
				D.disassociate()

				message_admins("[key_name_admin(usr)] removed [adm_ckey] from the admins list")
				log_admin("[key_name(usr)] removed [adm_ckey] from the admins list")
				log_admin_rank_modification(adm_ckey, "Removed")

		else if(task == "rank")
			var/new_rank
			if(admin_ranks.len)
				new_rank = input("Please select a rank", "New rank", null, null) as null|anything in (admin_ranks|"*New Rank*")
			else
				new_rank = input("Please select a rank", "New rank", null, null) as null|anything in list("Game Master","Game Admin", "Trial Admin", "Admin Observer","*New Rank*")

			var/rights = 0
			if(D)
				rights = D.rights
			switch(new_rank)
				if(null,"") return
				if("*New Rank*")
					new_rank = input("Please input a new rank", "New custom rank", null, null) as null|text
					if(config.admin_legacy_system)
						new_rank = ckeyEx(new_rank)
					if(!new_rank)
						usr << "<font color='red'>Error: Topic 'editrights': Invalid rank</font>"
						return
					if(config.admin_legacy_system)
						if(admin_ranks.len)
							if(new_rank in admin_ranks)
								rights = admin_ranks[new_rank]		//we typed a rank which already exists, use its rights
							else
								admin_ranks[new_rank] = 0			//add the new rank to admin_ranks
				else
					if(config.admin_legacy_system)
						new_rank = ckeyEx(new_rank)
						rights = admin_ranks[new_rank]				//we input an existing rank, use its rights

			if(D)
				D.disassociate()								//remove adminverbs and unlink from client
				D.rank = new_rank								//update the rank
				D.rights = rights								//update the rights based on admin_ranks (default: 0)
			else
				D = new /datum/admins(new_rank, rights, adm_ckey)

			var/client/C = directory[adm_ckey]						//find the client with the specified ckey (if they are logged in)
			D.associate(C)											//link up with the client and add verbs

			message_admins("[key_name_admin(usr)] edited the admin rank of [adm_ckey] to [new_rank]")
			log_admin("[key_name(usr)] edited the admin rank of [adm_ckey] to [new_rank]")
			log_admin_rank_modification(adm_ckey, new_rank)

		else if(task == "permissions")
			if(!D)	return
			var/list/permissionlist = list()
			for(var/i=1, i<=R_MAXPERMISSION, i<<=1)		//that <<= is shorthand for i = i << 1. Which is a left bitshift
				permissionlist[rights2text(i)] = i
			var/new_permission = input("Select a permission to turn on/off", "Permission toggle", null, null) as null|anything in permissionlist
			if(!new_permission)	return
			D.rights ^= permissionlist[new_permission]

			message_admins("[key_name_admin(usr)] toggled the [new_permission] permission of [adm_ckey]")
			log_admin("[key_name(usr)] toggled the [new_permission] permission of [adm_ckey]")
			log_admin_permission_modification(adm_ckey, permissionlist[new_permission])

		edit_admin_permissions()

	else if(href_list["call_shuttle"])
		if(!check_rights(R_ADMIN))	return


		switch(href_list["call_shuttle"])
			if("1")
				if ((!( ticker ) || !emergency_shuttle.location()))
					return
				if (emergency_shuttle.can_call())
					emergency_shuttle.call_evac()
					log_admin("[key_name(usr)] called the Emergency Shuttle")
					message_admins("\blue [key_name_admin(usr)] called the Emergency Shuttle to the station", 1)

			if("2")
				if (!( ticker ) || !emergency_shuttle.location())
					return
				if (emergency_shuttle.can_call())
					emergency_shuttle.call_evac()
					log_admin("[key_name(usr)] called the Emergency Shuttle")
					message_admins("\blue [key_name_admin(usr)] called the Emergency Shuttle to the station", 1)

				else if (emergency_shuttle.can_recall())
					emergency_shuttle.recall()
					log_admin("[key_name(usr)] sent the Emergency Shuttle back")
					message_admins("\blue [key_name_admin(usr)] sent the Emergency Shuttle back", 1)

		href_list["secretsadmin"] = "check_antagonist"

	else if(href_list["edit_shuttle_time"])
		if(!check_rights(R_SERVER))	return

		if (emergency_shuttle.wait_for_launch)
			var/new_time_left = input("Enter new shuttle launch countdown (seconds):","Edit Shuttle Launch Time", emergency_shuttle.estimate_launch_time() ) as num

			emergency_shuttle.launch_time = world.time + new_time_left*10

			log_admin("[key_name(usr)] edited the Emergency Shuttle's launch time to [new_time_left]")
			message_admins("\blue [key_name_admin(usr)] edited the Emergency Shuttle's launch time to [new_time_left*10]", 1)
		else if (emergency_shuttle.shuttle.has_arrive_time())

			var/new_time_left = input("Enter new shuttle arrival time (seconds):","Edit Shuttle Arrival Time", emergency_shuttle.estimate_arrival_time() ) as num
			emergency_shuttle.shuttle.arrive_time = world.time + new_time_left*10

			log_admin("[key_name(usr)] edited the Emergency Shuttle's arrival time to [new_time_left]")
			message_admins("\blue [key_name_admin(usr)] edited the Emergency Shuttle's arrival time to [new_time_left*10]", 1)
		else
			alert("The shuttle is neither counting down to launch nor is it in transit. Please try again when it is.")

		href_list["secretsadmin"] = "check_antagonist"

	else if(href_list["delay_round_end"])
		if(!check_rights(R_SERVER))	return

		ticker.delay_end = !ticker.delay_end
		log_admin("[key_name(usr)] [ticker.delay_end ? "delayed the round end" : "has made the round end normally"].")
		message_admins("\blue [key_name(usr)] [ticker.delay_end ? "delayed the round end" : "has made the round end normally"].", 1)
		href_list["secretsadmin"] = "check_antagonist"

	else if(href_list["simplemake"])
		if(!check_rights(R_SPAWN))	return

		var/mob/M = locate(href_list["mob"])
		if(!ismob(M))
			usr << "This can only be used on instances of type /mob"
			return

		var/delmob = 0
		switch(alert("Delete old mob?","Message","Yes","No","Cancel"))
			if("Cancel")	return
			if("Yes")		delmob = 1

		log_admin("[key_name(usr)] has used rudimentary transformation on [key_name(M)]. Transforming to [href_list["simplemake"]]; deletemob=[delmob]")
		message_admins("\blue [key_name_admin(usr)] has used rudimentary transformation on [key_name_admin(M)]. Transforming to [href_list["simplemake"]]; deletemob=[delmob]", 1)

		switch(href_list["simplemake"])
			if("observer")			M.change_mob_type( /mob/dead/observer , null, null, delmob, 1 )
			if("drone")				M.change_mob_type( /mob/living/carbon/alien/humanoid/drone , null, null, delmob, 1 )
			if("hunter")			M.change_mob_type( /mob/living/carbon/alien/humanoid/hunter , null, null, delmob, 1 )
			if("queen")				M.change_mob_type( /mob/living/carbon/alien/humanoid/queen/large , null, null, delmob, 1 )
			if("sentinel")			M.change_mob_type( /mob/living/carbon/alien/humanoid/sentinel , null, null, delmob, 1 )
			if("larva")				M.change_mob_type( /mob/living/carbon/alien/larva , null, null, delmob, 1 )
			if("human")				M.change_mob_type( /mob/living/carbon/human/human , null, null, delmob, 1 )
			if("slime")				M.change_mob_type( /mob/living/carbon/slime , null, null, delmob, 1 )
			if("monkey")			M.change_mob_type( /mob/living/carbon/human/monkey , null, null, delmob, 1 )
			if("robot")				M.change_mob_type( /mob/living/silicon/robot , null, null, delmob, 1 )
			if("cat")				M.change_mob_type( /mob/living/simple_animal/pet/cat , null, null, delmob, 1 )
			if("HappyKitten")		M.change_mob_type( /mob/living/simple_animal/pet/cat/HappyKitten , null, null, delmob, 1 )
			if("corgi")				M.change_mob_type( /mob/living/simple_animal/pet/corgi , null, null, delmob, 1 )
			if("ian")				M.change_mob_type( /mob/living/simple_animal/pet/corgi/Ian , null, null, delmob, 1 )
			if("crab")				M.change_mob_type( /mob/living/simple_animal/crab , null, null, delmob, 1 )
			if("coffee")			M.change_mob_type( /mob/living/simple_animal/crab/Coffee , null, null, delmob, 1 )
			if("parrot")			M.change_mob_type( /mob/living/simple_animal/parrot , null, null, delmob, 1 )
			if("polyparrot")		M.change_mob_type( /mob/living/simple_animal/parrot/Poly , null, null, delmob, 1 )
			if("constructarmoured")	M.change_mob_type( /mob/living/simple_animal/construct/armoured , null, null, delmob, 1 )
			if("constructbuilder")	M.change_mob_type( /mob/living/simple_animal/construct/builder , null, null, delmob, 1 )
			if("constructwraith")	M.change_mob_type( /mob/living/simple_animal/construct/wraith , null, null, delmob, 1 )
			if("shade")				M.change_mob_type( /mob/living/simple_animal/shade , null, null, delmob, 1 )


	/////////////////////////////////////new ban stuff
	else if(href_list["unbanf"])
		if(!check_rights(R_BAN))	return

		var/banfolder = href_list["unbanf"]
		Banlist.cd = "/base/[banfolder]"
		var/key = Banlist["key"]
		if(alert(usr, "Are you sure you want to unban [key]?", "Confirmation", "Yes", "No") == "Yes")
			if(RemoveBan(banfolder))
				unbanpanel()
			else
				alert(usr, "This ban has already been lifted / does not exist.", "Error", "Ok")
				unbanpanel()

	else if(href_list["warn"])
		usr.client.warn(href_list["warn"])

	else if(href_list["unbane"])
		if(!check_rights(R_BAN))	return

		UpdateTime()
		var/reason

		var/banfolder = href_list["unbane"]
		Banlist.cd = "/base/[banfolder]"
		var/reason2 = Banlist["reason"]
		var/temp = Banlist["temp"]

		var/minutes = Banlist["minutes"]

		var/banned_key = Banlist["key"]
		Banlist.cd = "/base"

		var/duration

		switch(alert("Temporary Ban?",,"Yes","No"))
			if("Yes")
				temp = 1
				var/mins = 0
				if(minutes > CMinutes)
					mins = minutes - CMinutes
				mins = input(usr,"How long (in minutes)? (Default: 1440)","Ban time",mins ? mins : 1440) as num|null
				if(!mins)	return
				mins = min(525599,mins)
				minutes = CMinutes + mins
				duration = GetExp(minutes)
				reason = input(usr,"Reason?","reason",reason2) as text|null
				if(!reason)	return
			if("No")
				temp = 0
				duration = "Perma"
				reason = input(usr,"Reason?","reason",reason2) as text|null
				if(!reason)	return

		log_admin("[key_name(usr)] edited [banned_key]'s ban. Reason: [reason] Duration: [duration]")
		ban_unban_log_save("[key_name(usr)] edited [banned_key]'s ban. Reason: [reason] Duration: [duration]")
		message_admins("\blue [key_name_admin(usr)] edited [banned_key]'s ban. Reason: [reason] Duration: [duration]", 1)
		Banlist.cd = "/base/[banfolder]"
		Banlist["reason"] << reason
		Banlist["temp"] << temp
		Banlist["minutes"] << minutes
		Banlist["bannedby"] << usr.ckey
		Banlist.cd = "/base"
		feedback_inc("ban_edit",1)
		unbanpanel()

	/////////////////////////////////////new ban stuff

	else if(href_list["appearanceban"])
		if(!check_rights(R_BAN))
			return
		var/mob/M = locate(href_list["appearanceban"])
		if(!ismob(M))
			usr << "This can only be used on instances of type /mob"
			return
		if(!M.ckey)	//sanity
			usr << "This mob has no ckey"
			return

		var/banreason = appearance_isbanned(M)
		if(banreason)
	/*		if(!config.ban_legacy_system)
				usr << "Unfortunately, database based unbanning cannot be done through this panel"
				DB_ban_panel(M.ckey)
				return	*/
			switch(alert("Reason: '[banreason]' Remove appearance ban?","Please Confirm","Yes","No"))
				if("Yes")
					ban_unban_log_save("[key_name(usr)] removed [key_name(M)]'s appearance ban")
					log_admin("[key_name(usr)] removed [key_name(M)]'s appearance ban")
					feedback_inc("ban_appearance_unban", 1)
					DB_ban_unban(M.ckey, BANTYPE_APPEARANCE)
					appearance_unban(M)
					message_admins("\blue [key_name_admin(usr)] removed [key_name_admin(M)]'s appearance ban", 1)
					M << "\red<BIG><B>[usr.client.ckey] has removed your appearance ban.</B></BIG>"

		else switch(alert("Appearance ban [M.ckey]?",,"Yes","No", "Cancel"))
			if("Yes")
				var/reason = input(usr,"Reason?","reason","Metafriender") as text|null
				if(!reason)
					return
				ban_unban_log_save("[key_name(usr)] appearance banned [key_name(M)]. reason: [reason]")
				log_admin("[key_name(usr)] appearance banned [key_name(M)]. \nReason: [reason]")
				feedback_inc("ban_appearance",1)
				DB_ban_record(BANTYPE_APPEARANCE, M, -1, reason)
				appearance_fullban(M, "[reason]; By [usr.ckey] on [time2text(world.realtime)]")
				notes_add(M.ckey, "Appearance banned - [reason]")
				message_admins("\blue [key_name_admin(usr)] appearance banned [key_name_admin(M)]", 1)
				M << "\red<BIG><B>You have been appearance banned by [usr.client.ckey].</B></BIG>"
				M << "\red <B>The reason is: [reason]</B>"
				M << "\red Appearance ban can be lifted only upon request."
				if(config.banappeals)
					M << "\red To try to resolve this matter head to [config.banappeals]"
				else
					M << "\red No ban appeals URL has been set."
			if("No")
				return

	else if(href_list["jobban2"])
//		if(!check_rights(R_BAN))	return

		var/mob/M = locate(href_list["jobban2"])
		if(!ismob(M))
			usr << "This can only be used on instances of type /mob"
			return

		if(!M.ckey)	//sanity
			usr << "This mob has no ckey"
			return
		if(!job_master)
			usr << "Job Master has not been setup!"
			return

		var/dat = ""
		var/header = "<head><title>Job-Ban Panel: [M.name]</title></head>"
		var/body
		var/jobs = ""

	/***********************************WARNING!************************************
				      The jobban stuff looks mangled and disgusting
						      But it looks beautiful in-game
						                -Nodrak
	************************************WARNING!***********************************/
		var/counter = 0
//Regular jobs
	//Command (Blue)
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr align='center' bgcolor='ccccff'><th colspan='[length(command_positions)]'><a href='?src=\ref[src];jobban3=commanddept;jobban4=\ref[M]'>Command Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in command_positions)
			if(!jobPos)	continue
			var/datum/job/job = job_master.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 6) //So things dont get squiiiiished!
				jobs += "</tr><tr>"
				counter = 0
		jobs += "</tr></table>"

	//Security (Red)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='ffddf0'><th colspan='[length(security_positions)]'><a href='?src=\ref[src];jobban3=securitydept;jobban4=\ref[M]'>Security Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in security_positions)
			if(!jobPos)	continue
			var/datum/job/job = job_master.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

	//Engineering (Yellow)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='fff5cc'><th colspan='[length(engineering_positions)]'><a href='?src=\ref[src];jobban3=engineeringdept;jobban4=\ref[M]'>Engineering Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in engineering_positions)
			if(!jobPos)	continue
			var/datum/job/job = job_master.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

	//Medical (White)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='ffeef0'><th colspan='[length(medical_positions)]'><a href='?src=\ref[src];jobban3=medicaldept;jobban4=\ref[M]'>Medical Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in medical_positions)
			if(!jobPos)	continue
			var/datum/job/job = job_master.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

	//Science (Purple)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='e79fff'><th colspan='[length(science_positions)]'><a href='?src=\ref[src];jobban3=sciencedept;jobban4=\ref[M]'>Science Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in science_positions)
			if(!jobPos)	continue
			var/datum/job/job = job_master.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

	//Support (Grey)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='dddddd'><th colspan='[length(support_positions)]'><a href='?src=\ref[src];jobban3=supportdept;jobban4=\ref[M]'>Support Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in support_positions)
			if(!jobPos)	continue
			var/datum/job/job = job_master.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

	//Non-Human (Green)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='ccffcc'><th colspan='[length(nonhuman_positions)+1]'><a href='?src=\ref[src];jobban3=nonhumandept;jobban4=\ref[M]'>Non-human Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in nonhuman_positions)
			if(!jobPos)	continue
			var/datum/job/job = job_master.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0

		//Drone
		if(jobban_isbanned(M, "Drone"))
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=Drone;jobban4=\ref[M]'><font color=red>Drone</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=Drone;jobban4=\ref[M]'>Drone</a></td>"

		//pAI
		if(jobban_isbanned(M, "pAI"))
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=pAI;jobban4=\ref[M]'><font color=red>pAI</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=pAI;jobban4=\ref[M]'>pAI</a></td>"

		jobs += "</tr></table>"

	//Antagonist (Orange)
		var/isbanned_dept = jobban_isbanned(M, "Syndicate")
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='ffeeaa'><th colspan='10'><a href='?src=\ref[src];jobban3=Syndicate;jobban4=\ref[M]'>Antagonist Positions</a></th></tr><tr align='center'>"

		//Traitor
		if(jobban_isbanned(M, "traitor") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=traitor;jobban4=\ref[M]'><font color=red>[replacetext("Traitor", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=traitor;jobban4=\ref[M]'>[replacetext("Traitor", " ", "&nbsp")]</a></td>"

		//Changeling
		if(jobban_isbanned(M, "changeling") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=changeling;jobban4=\ref[M]'><font color=red>[replacetext("Changeling", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=changeling;jobban4=\ref[M]'>[replacetext("Changeling", " ", "&nbsp")]</a></td>"

		//Nuclear Operative
		if(jobban_isbanned(M, "operative") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=operative;jobban4=\ref[M]'><font color=red>[replacetext("Nuclear Operative", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=operative;jobban4=\ref[M]'>[replacetext("Nuclear Operative", " ", "&nbsp")]</a></td>"

		//Revolutionary
		if(jobban_isbanned(M, "revolutionary") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=revolutionary;jobban4=\ref[M]'><font color=red>[replacetext("Revolutionary", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=revolutionary;jobban4=\ref[M]'>[replacetext("Revolutionary", " ", "&nbsp")]</a></td>"

		//Cultist
		if(jobban_isbanned(M, "cultist") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=cultist;jobban4=\ref[M]'><font color=red>[replacetext("Cultist", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=cultist;jobban4=\ref[M]'>[replacetext("Cultist", " ", "&nbsp")]</a></td>"

		//Wizard
		if(jobban_isbanned(M, "wizard") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=wizard;jobban4=\ref[M]'><font color=red>[replacetext("Wizard", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=wizard;jobban4=\ref[M]'>[replacetext("Wizard", " ", "&nbsp")]</a></td>"

		jobs += "</tr><tr align='center'>" //Breaking it up so it fits nicer on the screen every 5 entries

/*		//Malfunctioning AI	//Removed Malf-bans because they're a pain to impliment
		if(jobban_isbanned(M, "malf AI") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=malf AI;jobban4=\ref[M]'><font color=red>[replacetext("Malf AI", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=malf AI;jobban4=\ref[M]'>[replacetext("Malf AI", " ", "&nbsp")]</a></td>"
*/

		//Alien
		if(jobban_isbanned(M, "alien") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=alien;jobban4=\ref[M]'><font color=red>[replacetext("Alien", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=alien;jobban4=\ref[M]'>[replacetext("Alien", " ", "&nbsp")]</a></td>"

		//Ninja
		if(jobban_isbanned(M, "ninja") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=ninja;jobban4=\ref[M]'><font color=red>[replacetext("Ninja", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=ninja;jobban4=\ref[M]'>[replacetext("Ninja", " ", "&nbsp")]</a></td>"

		//Raider
		if(jobban_isbanned(M, "raider") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=raider;jobban4=\ref[M]'><font color=red>[replacetext("Raider", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=raider;jobban4=\ref[M]'>[replacetext("Raider", " ", "&nbsp")]</a></td>"

		//Mutineer
		if(jobban_isbanned(M, "mutineer") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=mutineer;jobban4=\ref[M]'><font color=red>[replacetext("Mutineer", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=mutineer;jobban4=\ref[M]'>[replacetext("Mutineer", " ", "&nbsp")]</a></td>"

		//Blob
		if(jobban_isbanned(M, "blob") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=blob;jobban4=\ref[M]'><font color=red>[replacetext("Blob", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=blob;jobban4=\ref[M]'>[replacetext("Blob", " ", "&nbsp")]</a></td>"

		jobs += "</tr></table>"


		//Other races  (BLUE, because I have no idea what other color to make this)
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='ccccff'><th colspan='4'>Other</th></tr><tr align='center'>"

		//NYMPH
		if(jobban_isbanned(M, "Dionaea"))
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=Dionaea;jobban4=\ref[M]'><font color=red>Dionaea Nymph</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=Dionaea;jobban4=\ref[M]'>Dionaea Nymph</a></td>"

		//NPC
		if(jobban_isbanned(M, "NPC"))
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=NPC;jobban4=\ref[M]'><font color=red>NPC</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=NPC;jobban4=\ref[M]'>NPC</a></td>"

		//ANTAG HUD
		if(jobban_isbanned(M, "AntagHUD"))
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=AntagHUD;jobban4=\ref[M]'><font color=red>AntagHUD</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=AntagHUD;jobban4=\ref[M]'>AntagHUD</a></td>"

		//ERT
		if(jobban_isbanned(M, "Emergency Response Team") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=Emergency Response Team;jobban4=\ref[M]'><font color=red>Emergency Response Team</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=Emergency Response Team;jobban4=\ref[M]'>Emergency Response Team</a></td>"

		jobs += "</tr></table>"

	//Support (Grey)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='dddddd'><th colspan='[length(whitelisted_positions)]'><a href='?src=\ref[src];jobban3=whitelistdept;jobban4=\ref[M]'>Whitelisted Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in whitelisted_positions)
			if(!jobPos)	continue
			var/datum/job/job = job_master.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

		body = "<body>[jobs]</body>"
		dat = "<tt>[header][body]</tt>"
		usr << browse(dat, "window=jobban2;size=800x490")
		return

	//JOBBAN'S INNARDS
	else if(href_list["jobban3"])
		if(!check_rights(R_BAN))	return

		var/mob/M = locate(href_list["jobban4"])
		if(!ismob(M))
			usr << "This can only be used on instances of type /mob"
			return

		if(M != usr)																//we can jobban ourselves
			if(M.client && M.client.holder && (M.client.holder.rights & R_BAN))		//they can ban too. So we can't ban them
				alert("You cannot perform this action. You must be of a higher administrative rank!")
				return

		if(!job_master)
			usr << "Job Master has not been setup!"
			return

		//get jobs for department if specified, otherwise just returnt he one job in a list.
		var/list/joblist = list()
		switch(href_list["jobban3"])
			if("commanddept")
				for(var/jobPos in command_positions)
					if(!jobPos)	continue
					var/datum/job/temp = job_master.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("securitydept")
				for(var/jobPos in security_positions)
					if(!jobPos)	continue
					var/datum/job/temp = job_master.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("engineeringdept")
				for(var/jobPos in engineering_positions)
					if(!jobPos)	continue
					var/datum/job/temp = job_master.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("medicaldept")
				for(var/jobPos in medical_positions)
					if(!jobPos)	continue
					var/datum/job/temp = job_master.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("sciencedept")
				for(var/jobPos in science_positions)
					if(!jobPos)	continue
					var/datum/job/temp = job_master.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("supportdept")
				for(var/jobPos in support_positions)
					if(!jobPos)	continue
					var/datum/job/temp = job_master.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("nonhumandept")
				joblist += "pAI"
				for(var/jobPos in nonhuman_positions)
					if(!jobPos)	continue
					var/datum/job/temp = job_master.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("whitelistdept")
				for(var/jobPos in whitelisted_positions)
					if(!jobPos)	continue
					var/datum/job/temp = job_master.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			else
				joblist += href_list["jobban3"]

		//Create a list of unbanned jobs within joblist
		var/list/notbannedlist = list()
		for(var/job in joblist)
			if(!jobban_isbanned(M, job))
				notbannedlist += job

		//Banning comes first
		if(notbannedlist.len) //at least 1 unbanned job exists in joblist so we have stuff to ban.
			switch(alert("Temporary Ban?",,"Yes","No", "Cancel"))
				if("Yes")
					if(config.ban_legacy_system)
						usr << "\red Your server is using the legacy banning system, which does not support temporary job bans. Consider upgrading. Aborting ban."
						return
					var/mins = input(usr,"How long (in minutes)?","Ban time",1440) as num|null
					if(!mins)
						return
					var/reason = input(usr,"Reason?","Please State Reason","") as text|null
					if(!reason)
						return

					var/msg
					for(var/job in notbannedlist)
						ban_unban_log_save("[key_name(usr)] temp-jobbanned [key_name(M)] from [job] for [mins] minutes. reason: [reason]")
						log_admin("[key_name(usr)] temp-jobbanned [key_name(M)] from [job] for [mins] minutes")
						feedback_inc("ban_job_tmp",1)
						DB_ban_record(BANTYPE_JOB_TEMP, M, mins, reason, job)
						feedback_add_details("ban_job_tmp","- [job]")
						jobban_fullban(M, job, "[reason]; By [usr.ckey] on [time2text(world.realtime)]") //Legacy banning does not support temporary jobbans.
						if(!msg)
							msg = job
						else
							msg += ", [job]"
					notes_add(M.ckey, "Banned  from [msg] - [reason]")
					message_admins("\blue [key_name_admin(usr)] banned [key_name_admin(M)] from [msg] for [mins] minutes", 1)
					M << "\red<BIG><B>You have been jobbanned by [usr.client.ckey] from: [msg].</B></BIG>"
					M << "\red <B>The reason is: [reason]</B>"
					M << "\red This jobban will be lifted in [mins] minutes."
					href_list["jobban2"] = 1 // lets it fall through and refresh
					return 1
				if("No")
					var/reason = input(usr,"Reason?","Please State Reason","") as text|null
					if(reason)
						var/msg
						for(var/job in notbannedlist)
							ban_unban_log_save("[key_name(usr)] perma-jobbanned [key_name(M)] from [job]. reason: [reason]")
							log_admin("[key_name(usr)] perma-banned [key_name(M)] from [job]")
							feedback_inc("ban_job",1)
							DB_ban_record(BANTYPE_JOB_PERMA, M, -1, reason, job)
							feedback_add_details("ban_job","- [job]")
							jobban_fullban(M, job, "[reason]; By [usr.ckey] on [time2text(world.realtime)]")
							if(!msg)	msg = job
							else		msg += ", [job]"
						notes_add(M.ckey, "Banned  from [msg] - [reason]")
						message_admins("\blue [key_name_admin(usr)] banned [key_name_admin(M)] from [msg]", 1)
						M << "\red<BIG><B>You have been jobbanned by [usr.client.ckey] from: [msg].</B></BIG>"
						M << "\red <B>The reason is: [reason]</B>"
						M << "\red Jobban can be lifted only upon request."
						href_list["jobban2"] = 1 // lets it fall through and refresh
						return 1
				if("Cancel")
					return

		//Unbanning joblist
		//all jobs in joblist are banned already OR we didn't give a reason (implying they shouldn't be banned)
		if(joblist.len) //at least 1 banned job exists in joblist so we have stuff to unban.
			if(!config.ban_legacy_system)
				usr << "Unfortunately, database based unbanning cannot be done through this panel"
				DB_ban_panel(M.ckey)
				return
			var/msg
			for(var/job in joblist)
				var/reason = jobban_isbanned(M, job)
				if(!reason) continue //skip if it isn't jobbanned anyway
				switch(alert("Job: '[job]' Reason: '[reason]' Un-jobban?","Please Confirm","Yes","No"))
					if("Yes")
						ban_unban_log_save("[key_name(usr)] unjobbanned [key_name(M)] from [job]")
						log_admin("[key_name(usr)] unbanned [key_name(M)] from [job]")
						DB_ban_unban(M.ckey, BANTYPE_JOB_PERMA, job)
						feedback_inc("ban_job_unban",1)
						feedback_add_details("ban_job_unban","- [job]")
						jobban_unban(M, job)
						if(!msg)	msg = job
						else		msg += ", [job]"
					else
						continue
			if(msg)
				message_admins("\blue [key_name_admin(usr)] unbanned [key_name_admin(M)] from [msg]", 1)
				M << "\red<BIG><B>You have been un-jobbanned by [usr.client.ckey] from [msg].</B></BIG>"
				href_list["jobban2"] = 1 // lets it fall through and refresh
			return 1
		return 0 //we didn't do anything!

	else if(href_list["boot2"])
		var/mob/M = locate(href_list["boot2"])
		if (ismob(M))
			if(!check_if_greater_rights_than(M.client))
				return
			M << "\red You have been kicked from the server"
			log_admin("[key_name(usr)] booted [key_name(M)].")
			message_admins("\blue [key_name_admin(usr)] booted [key_name_admin(M)].", 1)
			//M.client = null
			del(M.client)
/*
	//Player Notes
	else if(href_list["notes"])
		var/ckey = href_list["ckey"]
		if(!ckey)
			var/mob/M = locate(href_list["mob"])
			if(ismob(M))
				ckey = M.ckey

		switch(href_list["notes"])
			if("show")
				notes_show(ckey)
			if("add")
				notes_add(ckey,href_list["text"])
				notes_show(ckey)
			if("remove")
				notes_remove(ckey,text2num(href_list["from"]),text2num(href_list["to"]))
				notes_show(ckey)
*/
	else if(href_list["removejobban"])
		if(!check_rights(R_BAN))	return

		var/t = href_list["removejobban"]
		if(t)
			if((alert("Do you want to unjobban [t]?","Unjobban confirmation", "Yes", "No") == "Yes") && t) //No more misclicks! Unless you do it twice.
				log_admin("[key_name(usr)] removed [t]")
				message_admins("\blue [key_name_admin(usr)] removed [t]", 1)
				jobban_remove(t)
				href_list["ban"] = 1 // lets it fall through and refresh
				var/t_split = text2list(t, " - ")
				var/key = t_split[1]
				var/job = t_split[2]
				DB_ban_unban(ckey(key), BANTYPE_JOB_PERMA, job)

	else if(href_list["newban"])
		if(!check_rights(R_BAN))	return

		var/mob/M = locate(href_list["newban"])
		if(!ismob(M)) return

		if(M.client && M.client.holder)	return	//admins cannot be banned. Even if they could, the ban doesn't affect them anyway

		switch(alert("Temporary Ban?",,"Yes","No", "Cancel"))
			if("Yes")
				var/mins = input(usr,"How long (in minutes)?","Ban time",1440) as num|null
				if(!mins)
					return
				if(mins >= 525600) mins = 525599
				var/reason = input(usr,"Reason?","reason","Griefer") as text|null
				if(!reason)
					return
				AddBan(M.ckey, M.computer_id, reason, usr.ckey, 1, mins)
				ban_unban_log_save("[usr.client.ckey] has banned [M.ckey]. - Reason: [reason] - This will be removed in [mins] minutes.")
				M << "\red<BIG><B>You have been banned by [usr.client.ckey].\nReason: [reason].</B></BIG>"
				M << "\red This is a temporary ban, it will be removed in [mins] minutes."
				feedback_inc("ban_tmp",1)
				DB_ban_record(BANTYPE_TEMP, M, mins, reason)
				feedback_inc("ban_tmp_mins",mins)
				if(config.banappeals)
					M << "\red To try to resolve this matter head to [config.banappeals]"
				else
					M << "\red No ban appeals URL has been set."
				log_admin("[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis will be removed in [mins] minutes.")
				message_admins("\blue[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis will be removed in [mins] minutes.")

				del(M.client)
				//del(M)	// See no reason why to delete mob. Important stuff can be lost. And ban can be lifted before round ends.
			if("No")
				var/reason = input(usr,"Reason?","reason","Griefer") as text|null
				if(!reason)
					return
				switch(alert(usr,"IP ban?",,"Yes","No","Cancel"))
					if("Cancel")	return
					if("Yes")
						AddBan(M.ckey, M.computer_id, reason, usr.ckey, 0, 0, M.lastKnownIP)
					if("No")
						AddBan(M.ckey, M.computer_id, reason, usr.ckey, 0, 0)
				M << "\red<BIG><B>You have been banned by [usr.client.ckey].\nReason: [reason].</B></BIG>"
				M << "\red This is a permanent ban."
				if(config.banappeals)
					M << "\red To try to resolve this matter head to [config.banappeals]"
				else
					M << "\red No ban appeals URL has been set."
				ban_unban_log_save("[usr.client.ckey] has permabanned [M.ckey]. - Reason: [reason] - This is a permanent ban.")
				log_admin("[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis is a permanent ban.")
				message_admins("\blue[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis is a permanent ban.")
				feedback_inc("ban_perma",1)
				DB_ban_record(BANTYPE_PERMA, M, -1, reason)

				del(M.client)
				//del(M)
			if("Cancel")
				return

	else if(href_list["mute"])
		if(!check_rights(R_MOD))
			return

		var/mob/M = locate(href_list["mute"])
		if(!ismob(M))	return
		if(!M.client)	return

		var/mute_type = href_list["mute_type"]
		if(istext(mute_type))	mute_type = text2num(mute_type)
		if(!isnum(mute_type))	return

		cmd_admin_mute(M, mute_type)

	else if(href_list["c_mode"])
		if(!check_rights(R_ADMIN))	return

		if(ticker && ticker.mode)
			return alert(usr, "The game has already started.", null, null, null, null)
		var/dat = {"<B>What mode do you wish to play?</B><HR>"}
		for(var/mode in config.modes)
			dat += {"<A href='?src=\ref[src];c_mode2=[mode]'>[config.mode_names[mode]]</A><br>"}
		dat += {"<A href='?src=\ref[src];c_mode2=secret'>Secret</A><br>"}
		dat += {"<A href='?src=\ref[src];c_mode2=random'>Random</A><br>"}
		dat += {"Now: [master_mode]"}
		usr << browse(dat, "window=c_mode")

	else if(href_list["f_secret"])
		if(!check_rights(R_ADMIN))	return

		if(ticker && ticker.mode)
			return alert(usr, "The game has already started.", null, null, null, null)
		if(master_mode != "secret")
			return alert(usr, "The game mode has to be secret!", null, null, null, null)
		var/dat = {"<B>What game mode do you want to force secret to be? Use this if you want to change the game mode, but want the players to believe it's secret. This will only work if the current game mode is secret.</B><HR>"}
		for(var/mode in config.modes)
			dat += {"<A href='?src=\ref[src];f_secret2=[mode]'>[config.mode_names[mode]]</A><br>"}
		dat += {"<A href='?src=\ref[src];f_secret2=secret'>Random (default)</A><br>"}
		dat += {"Now: [secret_force_mode]"}
		usr << browse(dat, "window=f_secret")

	else if(href_list["c_mode2"])
		if(!check_rights(R_ADMIN|R_SERVER))	return

		if (ticker && ticker.mode)
			return alert(usr, "The game has already started.", null, null, null, null)
		master_mode = href_list["c_mode2"]
		log_admin("[key_name(usr)] set the mode as [master_mode].")
		message_admins("\blue [key_name_admin(usr)] set the mode as [master_mode].", 1)
		world << "\blue <b>The mode is now: [master_mode]</b>"
		Game() // updates the main game menu
		world.save_mode(master_mode)
		.(href, list("c_mode"=1))

	else if(href_list["f_secret2"])
		if(!check_rights(R_ADMIN|R_SERVER))	return

		if(ticker && ticker.mode)
			return alert(usr, "The game has already started.", null, null, null, null)
		if(master_mode != "secret")
			return alert(usr, "The game mode has to be secret!", null, null, null, null)
		secret_force_mode = href_list["f_secret2"]
		log_admin("[key_name(usr)] set the forced secret mode as [secret_force_mode].")
		message_admins("\blue [key_name_admin(usr)] set the forced secret mode as [secret_force_mode].", 1)
		Game() // updates the main game menu
		.(href, list("f_secret"=1))

	else if(href_list["monkeyone"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["monkeyone"])
		if(!istype(H))
			usr << "This can only be used on instances of type /mob/living/carbon/human"
			return

		log_admin("[key_name(usr)] attempting to monkeyize [key_name(H)]")
		message_admins("\blue [key_name_admin(usr)] attempting to monkeyize [key_name_admin(H)]", 1)
		H.monkeyize()


	else if(href_list["corgione"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["corgione"])
		if(!istype(H))
			usr << "This can only be used on instances of type /mob/living/carbon/human"
			return

		log_admin("[key_name(usr)] attempting to corgize [key_name(H)]")
		message_admins("\blue [key_name_admin(usr)] attempting to corgize [key_name_admin(H)]", 1)
		H.corgize()

	else if(href_list["forcespeech"])
		if(!check_rights(R_SERVER|R_EVENT))	return

		var/mob/M = locate(href_list["forcespeech"])
		if(!ismob(M))
			usr << "this can only be used on instances of type /mob"

		var/speech = input("What will [key_name(M)] say?.", "Force speech", "")// Don't need to sanitize, since it does that in say(), we also trust our admins.
		if(!speech)	return
		M.say(speech)
		speech = sanitize(speech) // Nah, we don't trust them
		log_admin("[key_name(usr)] forced [key_name(M)] to say: [speech]")
		message_admins("\blue [key_name_admin(usr)] forced [key_name_admin(M)] to say: [speech]")

	else if(href_list["sendtoprison"])
		if(!check_rights(R_ADMIN))	return

		if(alert(usr, "Send to admin prison for the round?", "Message", "Yes", "No") != "Yes")
			return

		var/mob/M = locate(href_list["sendtoprison"])
		if(!ismob(M))
			usr << "This can only be used on instances of type /mob"
			return
		if(istype(M, /mob/living/silicon/ai))
			usr << "This cannot be used on instances of type /mob/living/silicon/ai"
			return

		var/turf/prison_cell = pick(prisonwarp)
		if(!prison_cell)	return

		var/obj/structure/closet/secure_closet/brig/locker = new /obj/structure/closet/secure_closet/brig(prison_cell)
		locker.opened = 0
		locker.locked = 1

		//strip their stuff and stick it in the crate
		for(var/obj/item/I in M)
			M.unEquip(I)
			if(I)
				I.loc = locker
				I.layer = initial(I.layer)
				I.dropped(M)
		M.update_icons()

		//so they black out before warping
		M.Paralyse(5)
		sleep(5)
		if(!M)	return

		M.loc = prison_cell
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/prisoner = M
			prisoner.equip_to_slot_or_del(new /obj/item/clothing/under/color/orange(prisoner), slot_w_uniform)
			prisoner.equip_to_slot_or_del(new /obj/item/clothing/shoes/orange(prisoner), slot_shoes)

		M << "\red You have been sent to the prison station!"
		log_admin("[key_name(usr)] sent [key_name(M)] to the prison station.")
		message_admins("\blue [key_name_admin(usr)] sent [key_name_admin(M)] to the prison station.", 1)

	else if(href_list["sendbacktolobby"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["sendbacktolobby"])

		if(!isobserver(M))
			usr << "<span class='notice'>You can only send ghost players back to the Lobby.</span>"
			return

		if(!M.client)
			usr << "<span class='warning'>[M] doesn't seem to have an active client.</span>"
			return

		if(alert(usr, "Send [key_name(M)] back to Lobby?", "Message", "Yes", "No") != "Yes")
			return

		log_admin("[key_name(usr)] has sent [key_name(M)] back to the Lobby.")
		message_admins("[key_name(usr)] has sent [key_name(M)] back to the Lobby.")

		var/mob/new_player/NP = new()
		NP.ckey = M.ckey
		qdel(M)

	else if(href_list["tdome1"])
		if(!check_rights(R_SERVER|R_EVENT))	return

		if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")
			return

		var/mob/M = locate(href_list["tdome1"])
		if(!ismob(M))
			usr << "This can only be used on instances of type /mob"
			return
		if(istype(M, /mob/living/silicon/ai))
			usr << "This cannot be used on instances of type /mob/living/silicon/ai"
			return

		for(var/obj/item/I in M)
			M.unEquip(I)
			if(I)
				I.loc = M.loc
				I.layer = initial(I.layer)
				I.dropped(M)

		M.Paralyse(5)
		sleep(5)
		M.loc = pick(tdome1)
		spawn(50)
			M << "\blue You have been sent to the Thunderdome."
		log_admin("[key_name(usr)] has sent [key_name(M)] to the thunderdome. (Team 1)")
		message_admins("[key_name_admin(usr)] has sent [key_name_admin(M)] to the thunderdome. (Team 1)", 1)

	else if(href_list["tdome2"])
		if(!check_rights(R_SERVER|R_EVENT))	return

		if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")
			return

		var/mob/M = locate(href_list["tdome2"])
		if(!ismob(M))
			usr << "This can only be used on instances of type /mob"
			return
		if(istype(M, /mob/living/silicon/ai))
			usr << "This cannot be used on instances of type /mob/living/silicon/ai"
			return

		for(var/obj/item/I in M)
			M.unEquip(I)
			if(I)
				I.loc = M.loc
				I.layer = initial(I.layer)
				I.dropped(M)

		M.Paralyse(5)
		sleep(5)
		M.loc = pick(tdome2)
		spawn(50)
			M << "\blue You have been sent to the Thunderdome."
		log_admin("[key_name(usr)] has sent [key_name(M)] to the thunderdome. (Team 2)")
		message_admins("[key_name_admin(usr)] has sent [key_name_admin(M)] to the thunderdome. (Team 2)", 1)

	else if(href_list["tdomeadmin"])
		if(!check_rights(R_SERVER|R_EVENT))	return

		if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")
			return

		var/mob/M = locate(href_list["tdomeadmin"])
		if(!ismob(M))
			usr << "This can only be used on instances of type /mob"
			return
		if(istype(M, /mob/living/silicon/ai))
			usr << "This cannot be used on instances of type /mob/living/silicon/ai"
			return

		M.Paralyse(5)
		sleep(5)
		M.loc = pick(tdomeadmin)
		spawn(50)
			M << "\blue You have been sent to the Thunderdome."
		log_admin("[key_name(usr)] has sent [key_name(M)] to the thunderdome. (Admin.)")
		message_admins("[key_name_admin(usr)] has sent [key_name_admin(M)] to the thunderdome. (Admin.)", 1)

	else if(href_list["tdomeobserve"])
		if(!check_rights(R_SERVER|R_EVENT))	return

		if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")
			return

		var/mob/M = locate(href_list["tdomeobserve"])
		if(!ismob(M))
			usr << "This can only be used on instances of type /mob"
			return
		if(istype(M, /mob/living/silicon/ai))
			usr << "This cannot be used on instances of type /mob/living/silicon/ai"
			return

		for(var/obj/item/I in M)
			M.unEquip(I)
			if(I)
				I.loc = M.loc
				I.layer = initial(I.layer)
				I.dropped(M)

		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/observer = M
			observer.equip_to_slot_or_del(new /obj/item/clothing/under/suit_jacket(observer), slot_w_uniform)
			observer.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(observer), slot_shoes)
		M.Paralyse(5)
		sleep(5)
		M.loc = pick(tdomeobserve)
		spawn(50)
			M << "\blue You have been sent to the Thunderdome."
		log_admin("[key_name(usr)] has sent [key_name(M)] to the thunderdome. (Observer.)")
		message_admins("[key_name_admin(usr)] has sent [key_name_admin(M)] to the thunderdome. (Observer.)", 1)

	else if(href_list["aroomwarp"])
		if(!check_rights(R_SERVER|R_EVENT))	return

		if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")
			return

		var/mob/M = locate(href_list["aroomwarp"])
		if(!ismob(M))
			usr << "This can only be used on instances of type /mob"
			return
		if(istype(M, /mob/living/silicon/ai))
			usr << "This cannot be used on instances of type /mob/living/silicon/ai"
			return

		M.Paralyse(5)
		sleep(5)
		M.loc = pick(aroomwarp)
		spawn(50)
			M << "\blue You have been sent to the <b>Admin Room!</b>."
		log_admin("[key_name(usr)] has sent [key_name(M)] to the Admin Room")
		message_admins("[key_name_admin(usr)] has sent [key_name_admin(M)] to the Admin Room", 1)


	else if(href_list["revive"])
		if(!check_rights(R_REJUVINATE))	return

		var/mob/living/L = locate(href_list["revive"])
		if(!istype(L))
			usr << "This can only be used on instances of type /mob/living"
			return

		L.revive()
		message_admins("\red Admin [key_name_admin(usr)] healed / revived [key_name_admin(L)]!", 1)
		log_admin("[key_name(usr)] healed / Revived [key_name(L)]")

	else if(href_list["makeai"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["makeai"])
		if(!istype(H))
			usr << "This can only be used on instances of type /mob/living/carbon/human"
			return

		message_admins("\red Admin [key_name_admin(usr)] AIized [key_name_admin(H)]!", 1)
		log_admin("[key_name(usr)] AIized [key_name(H)]")
		H.AIize()


	else if(href_list["makemask"])
		if(!check_rights(R_SPAWN))	return
		var/mob/currentMob = locate(href_list["makemask"])
		message_admins("\red Admin [key_name_admin(usr)] made [key_name_admin(currentMob)] into a Mask of Nar'Sie!", 1)
		log_admin("[key_name(usr)] made [key_name(currentMob)] into a Mask of Nar'Sie!")
		currentMob.make_into_mask(0,0)


	else if(href_list["makealien"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["makealien"])
		if(!istype(H))
			usr << "This can only be used on instances of type /mob/living/carbon/human"
			return

		usr.client.cmd_admin_alienize(H)

	else if(href_list["makeslime"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["makeslime"])
		if(!istype(H))
			usr << "This can only be used on instances of type /mob/living/carbon/human"
			return

		usr.client.cmd_admin_slimeize(H)

	else if(href_list["makesuper"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["makesuper"])
		if(!istype(H))
			usr << "This can only be used on instances of type /mob/living/carbon/human"
			return

		usr.client.cmd_admin_super(H)

	else if(href_list["makerobot"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["makerobot"])
		if(!istype(H))
			usr << "This can only be used on instances of type /mob/living/carbon/human"
			return

		usr.client.cmd_admin_robotize(H)

	else if(href_list["makeanimal"])
		if(!check_rights(R_SPAWN))	return

		var/mob/M = locate(href_list["makeanimal"])
		if(istype(M, /mob/new_player))
			usr << "This cannot be used on instances of type /mob/new_player"
			return

		usr.client.cmd_admin_animalize(M)

	else if(href_list["togmutate"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["togmutate"])
		if(!istype(H))
			usr << "This can only be used on instances of type /mob/living/carbon/human"
			return
		var/block=text2num(href_list["block"])
		//testing("togmutate([href_list["block"]] -> [block])")
		usr.client.cmd_admin_toggle_block(H,block)
		show_player_panel(H)
		//H.regenerate_icons()

	else if(href_list["adminplayeropts"])
		var/mob/M = locate(href_list["adminplayeropts"])
		show_player_panel(M)

	else if(href_list["adminplayerobservejump"])
		if(!check_rights(R_MOD,0) && !check_rights(R_ADMIN))	return

		var/mob/M = locate(href_list["adminplayerobservejump"])

		var/client/C = usr.client
		if(!isobserver(usr))	C.admin_ghost()
		sleep(2)
		C.jumptomob(M)

	else if(href_list["check_antagonist"])
		check_antagonists()

	else if(href_list["adminplayerobservecoodjump"])
		if(!check_rights(R_ADMIN))	return

		var/x = text2num(href_list["X"])
		var/y = text2num(href_list["Y"])
		var/z = text2num(href_list["Z"])

		var/client/C = usr.client
		if(!isobserver(usr))	C.admin_ghost()
		sleep(2)
		C.jumptocoord(x,y,z)

	else if(href_list["adminchecklaws"])
		output_ai_laws()

	else if(href_list["adminmoreinfo"])
		var/mob/M = locate(href_list["adminmoreinfo"])
		if(!ismob(M))
			usr << "This can only be used on instances of type /mob"
			return

		var/location_description = ""
		var/special_role_description = ""
		var/health_description = ""
		var/gender_description = ""
		var/turf/T = get_turf(M)

		//Location
		if(isturf(T))
			if(isarea(T.loc))
				location_description = "([M.loc == T ? "at coordinates " : "in [M.loc] at coordinates "] [T.x], [T.y], [T.z] in area <b>[T.loc]</b>)"
			else
				location_description = "([M.loc == T ? "at coordinates " : "in [M.loc] at coordinates "] [T.x], [T.y], [T.z])"

		//Job + antagonist
		if(M.mind)
			special_role_description = "Role: <b>[M.mind.assigned_role]</b>; Antagonist: <font color='red'><b>[M.mind.special_role]</b></font>; Has been rev: [(M.mind.has_been_rev)?"Yes":"No"]"
		else
			special_role_description = "Role: <i>Mind datum missing</i> Antagonist: <i>Mind datum missing</i>; Has been rev: <i>Mind datum missing</i>;"

		//Health
		if(isliving(M))
			var/mob/living/L = M
			var/status
			switch (M.stat)
				if (0) status = "Alive"
				if (1) status = "<font color='orange'><b>Unconscious</b></font>"
				if (2) status = "<font color='red'><b>Dead</b></font>"
			health_description = "Status = [status]"
			health_description += "<BR>Oxy: [L.getOxyLoss()] - Tox: [L.getToxLoss()] - Fire: [L.getFireLoss()] - Brute: [L.getBruteLoss()] - Clone: [L.getCloneLoss()] - Brain: [L.getBrainLoss()]"
		else
			health_description = "This mob type has no health to speak of."

		//Gener
		switch(M.gender)
			if(MALE,FEMALE)	gender_description = "[M.gender]"
			else			gender_description = "<font color='red'><b>[M.gender]</b></font>"

		src.owner << "<b>Info about [M.name]:</b> "
		src.owner << "Mob type = [M.type]; Gender = [gender_description] Damage = [health_description]"
		src.owner << "Name = <b>[M.name]</b>; Real_name = [M.real_name]; Mind_name = [M.mind?"[M.mind.name]":""]; Key = <b>[M.key]</b>;"
		src.owner << "Location = [location_description];"
		src.owner << "[special_role_description]"
		src.owner << "(<a href='?src=\ref[usr];priv_msg=\ref[M]'>PM</a>) (<A HREF='?src=\ref[src];adminplayeropts=\ref[M]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[M]'>VV</A>) (<A HREF='?src=\ref[src];subtlemessage=\ref[M]'>SM</A>) ([admin_jump_link(M, src)]) (<A HREF='?src=\ref[src];secretsadmin=check_antagonist'>CA</A>)"

	else if(href_list["adminspawncookie"])
		if(!check_rights(R_ADMIN|R_EVENT))	return

		var/mob/living/carbon/human/H = locate(href_list["adminspawncookie"])
		if(!ishuman(H))
			usr << "This can only be used on instances of type /mob/living/carbon/human"
			return

		H.equip_to_slot_or_del( new /obj/item/weapon/reagent_containers/food/snacks/cookie(H), slot_l_hand )
		if(!(istype(H.l_hand,/obj/item/weapon/reagent_containers/food/snacks/cookie)))
			H.equip_to_slot_or_del( new /obj/item/weapon/reagent_containers/food/snacks/cookie(H), slot_r_hand )
			if(!(istype(H.r_hand,/obj/item/weapon/reagent_containers/food/snacks/cookie)))
				log_admin("[key_name(H)] has their hands full, so they did not receive their cookie, spawned by [key_name(src.owner)].")
				message_admins("[key_name(H)] has their hands full, so they did not receive their cookie, spawned by [key_name(src.owner)].")
				return
			else
				H.update_inv_r_hand()//To ensure the icon appears in the HUD
		else
			H.update_inv_l_hand()
		log_admin("[key_name(H)] got their cookie, spawned by [key_name(src.owner)]")
		message_admins("[key_name(H)] got their cookie, spawned by [key_name(src.owner)]")
		feedback_inc("admin_cookies_spawned",1)
		H << "\blue Your prayers have been answered!! You received the <b>best cookie</b>!"

	else if(href_list["BlueSpaceArtillery"])
		if(!check_rights(R_ADMIN|R_EVENT))	return

		var/mob/living/M = locate(href_list["BlueSpaceArtillery"])
		if(!isliving(M))
			usr << "This can only be used on instances of type /mob/living"
			return

		if(alert(src.owner, "Are you sure you wish to hit [key_name(M)] with Bluespace Artillery?",  "Confirm Firing?" , "Yes" , "No") != "Yes")
			return

		if(BSACooldown)
			src.owner << "Standby. Reload cycle in progress. Gunnery crews ready in five seconds!"
			return

		BSACooldown = 1
		spawn(50)
			BSACooldown = 0

		M << "You've been hit by bluespace artillery!"
		log_admin("[key_name(M)] has been hit by Bluespace Artillery fired by [src.owner]")
		message_admins("[key_name(M)] has been hit by Bluespace Artillery fired by [src.owner]")

		var/obj/effect/stop/S
		S = new /obj/effect/stop
		S.victim = M
		S.loc = M.loc
		spawn(20)
			del(S)

		var/turf/simulated/floor/T = get_turf(M)
		if(istype(T))
			if(prob(80))	T.break_tile_to_plating()
			else			T.break_tile()

		if(M.health == 1)
			M.gib()
		else
			M.adjustBruteLoss( min( 99 , (M.health - 1) )    )
			M.Stun(20)
			M.Weaken(20)
			M.stuttering = 20

	else if(href_list["CentcommReply"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/living/carbon/human/H = locate(href_list["CentcommReply"])
		if(!istype(H))
			usr << "This can only be used on instances of type /mob/living/carbon/human"
			return
		if(!istype(H.l_ear, /obj/item/device/radio/headset) && !istype(H.r_ear, /obj/item/device/radio/headset))
			usr << "The person you are trying to contact is not wearing a headset"
			return

		var/input = input(src.owner, "Please enter a message to reply to [key_name(H)] via their headset.","Outgoing message from Centcomm", "")
		if(!input)	return

		src.owner << "You sent [input] to [H] via a secure channel."
		log_admin("[src.owner] replied to [key_name(H)]'s Centcomm message with the message [input].")
		message_admins("[src.owner] replied to [key_name(H)]'s Centcom message with: \"[input]\"")
		H << "You hear something crackle in your headset for a moment before a voice speaks.  \"Please stand by for a message from Central Command.  Message as follows. [input].  Message ends.\""

	else if(href_list["SyndicateReply"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/living/carbon/human/H = locate(href_list["SyndicateReply"])
		if(!istype(H))
			usr << "This can only be used on instances of type /mob/living/carbon/human"
			return
		if(H.stat != 0)
			usr << "The person you are trying to contact is not conscious."
			return
		if(!istype(H.l_ear, /obj/item/device/radio/headset) && !istype(H.r_ear, /obj/item/device/radio/headset))
			usr << "The person you are trying to contact is not wearing a headset"
			return

		var/input = input(src.owner, "Please enter a message to reply to [key_name(H)] via their headset.","Outgoing message from The Syndicate", "")
		if(!input)	return

		src.owner << "You sent [input] to [H] via a secure channel."
		log_admin("[src.owner] replied to [key_name(H)]'s Syndicate message with the message [input].")
		H << "You hear something crackle in your headset for a moment before a voice speaks.  \"Please stand by for a message from your benefactor.  Message as follows, agent. [input].  Message ends.\""

	else if(href_list["HONKReply"])
		var/mob/living/carbon/human/H = locate(href_list["HONKReply"])
		if(!istype(H))
			usr << "This can only be used on instances of type /mob/living/carbon/human"
			return
		if(!istype(H.l_ear, /obj/item/device/radio/headset) && !istype(H.r_ear, /obj/item/device/radio/headset))
			usr << "The person you are trying to contact is not wearing a headset"
			return

		var/input = input(src.owner, "Please enter a message to reply to [key_name(H)] via their headset.","Outgoing message from HONKplanet", "")
		if(!input)	return

		src.owner << "You sent [input] to [H] via a secure channel."
		log_admin("[src.owner] replied to [key_name(H)]'s HONKplanet message with the message [input].")
		H << "You hear something crackle in your headset for a moment before a voice speaks.  \"Please stand by for a message from your HONKbrothers.  Message as follows, HONK. [input].  Message ends, HONK.\""

	else if(href_list["AdminFaxView"])
		if(!check_rights(R_ADMIN))
			return

		var/obj/item/fax = locate(href_list["AdminFaxView"])
		if (istype(fax, /obj/item/weapon/paper))
			var/obj/item/weapon/paper/P = fax
			P.show_content(usr,1)
		else if (istype(fax, /obj/item/weapon/photo))
			var/obj/item/weapon/photo/H = fax
			H.show(usr)
		else if (istype(fax, /obj/item/weapon/paper_bundle))
			//having multiple people turning pages on a paper_bundle can cause issues
			//open a browse window listing the contents instead
			var/data = ""
			var/obj/item/weapon/paper_bundle/B = fax

			for (var/page = 1, page <= B.amount + 1, page++)
				var/obj/pageobj = B.contents[page]
				data += "<A href='?src=\ref[src];AdminFaxViewPage=[page];paper_bundle=\ref[B]'>Page [page] - [pageobj.name]</A><BR>"

			usr << browse(data, "window=[B.name]")
		else
			usr << "\red The faxed item is not viewable. This is probably a bug, and should be reported on the tracker: [fax.type]"

	else if (href_list["AdminFaxViewPage"])
		if(!check_rights(R_ADMIN))
			return

		var/page = text2num(href_list["AdminFaxViewPage"])
		var/obj/item/weapon/paper_bundle/bundle = locate(href_list["paper_bundle"])

		if (!bundle) return

		if (istype(bundle.contents[page], /obj/item/weapon/paper))
			var/obj/item/weapon/paper/P = bundle.contents[page]
			P.show_content(src.owner, 1)
		else if (istype(bundle.contents[page], /obj/item/weapon/photo))
			var/obj/item/weapon/photo/H = bundle.contents[page]
			H.show(src.owner)
		return

	else if(href_list["AdminFaxCreate"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/sender = locate(href_list["AdminFaxCreate"])
		var/obj/machinery/photocopier/faxmachine/fax = locate(href_list["originfax"])
		var/faxtype = href_list["faxtype"]
		var/reply_to = locate(href_list["replyto"])
		var/destination
		var/notify

		var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(null) //hopefully the null loc won't cause trouble for us

		if(!fax)
			var/list/departmentoptions = alldepartments + "All Departments"
			destination = input(usr, "To which department?", "Choose a department", "") as null|anything in departmentoptions
			if(!destination)
				del(P)
				return

			for(var/obj/machinery/photocopier/faxmachine/F in allfaxes)
				if(destination != "All Departments" && F.department == destination)
					fax = F


		var/input = input(src.owner, "Please enter a message to send a fax via secure connection. Use <br> for line breaks. Both pencode and HTML work.", "Outgoing message from Centcomm", "") as message|null
		if(!input)
			del(P)
			return
		input = P.parsepencode(input) // Encode everything from pencode to html

		var/customname = input(src.owner, "Pick a title for the fax.", "Fax Title") as text|null
		if(!customname)
			customname = "paper"

		var/stampname
		var/stamptype
		var/stampvalue
		var/sendername
		switch(faxtype)
			if("Central Command")
				stamptype = "icon"
				stampvalue = "cent"
				sendername = command_name()
			if("Syndicate")
				sendername = "UNKNOWN"
			if("Administrator")
				stamptype = input(src.owner, "Pick a stamp type.", "Stamp Type") as null|anything in list("icon","text","none")
				if(stamptype == "icon")
					stampname = input(src.owner, "Pick a stamp icon.", "Stamp Icon") as null|anything in list("centcom","granted","denied","clown")
					switch(stampname)
						if("centcom")
							stampvalue = "cent"
						if("granted")
							stampvalue = "ok"
						if("denied")
							stampvalue = "deny"
						if("clown")
							stampvalue = "clown"
				else if(stamptype == "text")
					stampvalue = input(src.owner, "What should the stamp say?", "Stamp Text") as text|null
				else if(stamptype == "none")
					stamptype = ""
				else
					del(P)
					return

				sendername = input(src.owner, "What organization does the fax come from? This determines the prefix of the paper (i.e. Central Command- Title). This is optional.", "Organization") as text|null

		if(sender)
			notify = alert(src.owner, "Would you like to inform the original sender that a fax has arrived?","Notify Sender","Yes","No")

		// Create the reply message
		if(sendername)
			P.name = "[sendername]- [customname]"
		else
			P.name = "[customname]"
		P.info = input
		P.update_icon()
		P.x = rand(-2, 0)
		P.y = rand(-1, 2)
		P.offset_x += P.x
		P.offset_y += P.y
		if(stamptype)
			var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
			stampoverlay.pixel_x = P.x
			stampoverlay.pixel_y = P.y

			if(!P.ico)
				P.ico = new
			P.ico += "paper_stamp-[stampvalue]"
			stampoverlay.icon_state = "paper_stamp-[stampvalue]"

			if(stamptype == "icon")
				if(!P.stamped)
					P.stamped = new
				P.stamped += /obj/item/weapon/stamp/centcom
				P.overlays += stampoverlay
				P.stamps += "<HR><img src=large_stamp-[stampvalue].png>"

			else if(stamptype == "text")
				if(!P.stamped)
					P.stamped = new
				P.stamped += /obj/item/weapon/stamp
				P.overlays += stampoverlay
				P.stamps += "<HR><i>[stampvalue]</i>"

		if(destination != "All Departments")
			if(!fax.receivefax(P))
				src.owner << "\red Message transmission failed."
				return
		else
			for(var/obj/machinery/photocopier/faxmachine/F in allfaxes)
				if((F.z in config.station_levels))
					if(!F.receivefax(P))
						src.owner << "\red Message transmission to [F.department] failed."

		var/datum/fax/admin/A = new /datum/fax/admin()
		A.name = P.name
		A.from_department = faxtype
		if(destination != "All Departments")
			A.to_department = fax.department
		else
			A.to_department = "All Departments"
		A.origin = "Administrator"
		A.message = P
		A.reply_to = reply_to
		A.sent_by = usr
		A.sent_at = world.time

		src.owner << "\blue Message transmitted successfully."
		if(notify == "Yes")
			var/mob/living/carbon/human/H = sender
			if(istype(H) && H.stat == 1 && (istype(H.l_ear, /obj/item/device/radio/headset) || istype(H.r_ear, /obj/item/device/radio/headset)))
				sender << "Your headset pings, notifying you that a reply to your fax has arrived."
		if(sender)
			log_admin("[key_name(src.owner)] replied to a fax message from [key_name(sender)]: [input]")
			message_admins("[key_name_admin(src.owner)] replied to a fax message from [key_name_admin(sender)] (<a href='?_src_=holder;AdminFaxView=\ref[P]'>VIEW</a>).", 1)
		else
			log_admin("[key_name(src.owner)] sent a fax message to [destination]: [input]")
			message_admins("[key_name_admin(src.owner)] sent a fax message to [destination] (<a href='?_src_=holder;AdminFaxView=\ref[P]'>VIEW</a>).", 1)
		return

	else if(href_list["refreshfaxpanel"])
		if(!check_rights(R_ADMIN))
			return

		fax_panel(usr)

	else if(href_list["jumpto"])
		if(!check_rights(R_ADMIN))	return

		var/mob/M = locate(href_list["jumpto"])
		usr.client.jumptomob(M)

	else if(href_list["getmob"])
		if(!check_rights(R_ADMIN))	return

		if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")	return
		var/mob/M = locate(href_list["getmob"])
		usr.client.Getmob(M)

	else if(href_list["sendmob"])
		if(!check_rights(R_ADMIN))	return

		var/mob/M = locate(href_list["sendmob"])
		usr.client.sendmob(M)

	else if(href_list["narrateto"])
		if(!check_rights(R_ADMIN))	return

		var/mob/M = locate(href_list["narrateto"])
		usr.client.cmd_admin_direct_narrate(M)

	else if(href_list["subtlemessage"])
		if(!check_rights(R_ADMIN))	return

		var/mob/M = locate(href_list["subtlemessage"])
		usr.client.cmd_admin_subtle_message(M)

	else if(href_list["traitor"])
		if(!check_rights(R_ADMIN|R_MOD))	return

		if(!ticker || !ticker.mode)
			alert("The game hasn't started yet!")
			return

		var/mob/M = locate(href_list["traitor"])
		if(!ismob(M))
			usr << "This can only be used on instances of type /mob."
			return
		show_traitor_panel(M)

	else if(href_list["create_object"])
		if(!check_rights(R_SPAWN))	return
		return create_object(usr)

	else if(href_list["quick_create_object"])
		if(!check_rights(R_SPAWN))	return
		return quick_create_object(usr)

	else if(href_list["create_turf"])
		if(!check_rights(R_SPAWN))	return
		return create_turf(usr)

	else if(href_list["create_mob"])
		if(!check_rights(R_SPAWN))	return
		return create_mob(usr)

	else if(href_list["object_list"])			//this is the laggiest thing ever
		if(!check_rights(R_SPAWN))	return

		var/atom/loc = usr.loc

		var/dirty_paths
		if (istext(href_list["object_list"]))
			dirty_paths = list(href_list["object_list"])
		else if (istype(href_list["object_list"], /list))
			dirty_paths = href_list["object_list"]

		var/paths = list()
		var/removed_paths = list()

		for(var/dirty_path in dirty_paths)
			var/path = text2path(dirty_path)
			if(!path)
				removed_paths += dirty_path
				continue
			else if(!ispath(path, /obj) && !ispath(path, /turf) && !ispath(path, /mob))
				removed_paths += dirty_path
				continue
			else if(ispath(path, /obj/item/weapon/gun/energy/pulse_rifle))
				if(!check_rights((R_SERVER|R_EVENT),0))
					removed_paths += dirty_path
					continue
			else if(ispath(path, /obj/item/weapon/melee/energy/blade))//Not an item one should be able to spawn./N
				if(!check_rights((R_SERVER|R_EVENT),0))
					removed_paths += dirty_path
					continue
			else if(ispath(path, /obj/effect/anomaly/bhole))
				if(!check_rights((R_SERVER|R_EVENT),0))
					removed_paths += dirty_path
					continue
			paths += path

		if(!paths)
			alert("The path list you sent is empty")
			return
		if(length(paths) > 5)
			alert("Select fewer object types, (max 5)")
			return
		else if(length(removed_paths))
			alert("Removed:\n" + list2text(removed_paths, "\n"))

		var/list/offset = text2list(href_list["offset"],",")
		var/number = dd_range(1, 100, text2num(href_list["object_count"]))
		var/X = offset.len > 0 ? text2num(offset[1]) : 0
		var/Y = offset.len > 1 ? text2num(offset[2]) : 0
		var/Z = offset.len > 2 ? text2num(offset[3]) : 0
		var/tmp_dir = href_list["object_dir"]
		var/obj_dir = tmp_dir ? text2num(tmp_dir) : 2
		if(!obj_dir || !(obj_dir in list(1,2,4,8,5,6,9,10)))
			obj_dir = 2
		var/obj_name = sanitize(href_list["object_name"])
		var/where = href_list["object_where"]
		if (!( where in list("onfloor","inhand","inmarked") ))
			where = "onfloor"

		if( where == "inhand" )
			usr << "Support for inhand not available yet. Will spawn on floor."
			where = "onfloor"

		if ( where == "inhand" )	//Can only give when human or monkey
			if ( !( ishuman(usr)  ) )
				usr << "Can only spawn in hand when you're a human or a monkey."
				where = "onfloor"
			else if ( usr.get_active_hand() )
				usr << "Your active hand is full. Spawning on floor."
				where = "onfloor"

		if ( where == "inmarked" )
			if ( !marked_datum )
				usr << "You don't have any object marked. Abandoning spawn."
				return
			else
				if ( !istype(marked_datum,/atom) )
					usr << "The object you have marked cannot be used as a target. Target must be of type /atom. Abandoning spawn."
					return

		var/atom/target //Where the object will be spawned
		switch ( where )
			if ( "onfloor" )
				switch (href_list["offset_type"])
					if ("absolute")
						target = locate(0 + X,0 + Y,0 + Z)
					if ("relative")
						target = locate(loc.x + X,loc.y + Y,loc.z + Z)
			if ( "inmarked" )
				target = marked_datum

		if(target)
			for (var/path in paths)
				for (var/i = 0; i < number; i++)
					if(path in typesof(/turf))
						var/turf/O = target
						var/turf/N = O.ChangeTurf(path)
						if(N)
							if(obj_name)
								N.name = obj_name
					else
						var/atom/O = new path(target)
						if(O)
							O.dir = obj_dir
							if(obj_name)
								O.name = obj_name
								if(istype(O,/mob))
									var/mob/M = O
									M.real_name = obj_name

		if (number == 1)
			log_admin("[key_name(usr)] created a [english_list(paths)]")
			for(var/path in paths)
				if(ispath(path, /mob))
					message_admins("[key_name_admin(usr)] created a [english_list(paths)]", 1)
					break
		else
			log_admin("[key_name(usr)] created [number]ea [english_list(paths)]")
			for(var/path in paths)
				if(ispath(path, /mob))
					message_admins("[key_name_admin(usr)] created [number]ea [english_list(paths)]", 1)
					break
		return

	else if(href_list["secretsfun"])
		if(!check_rights(R_SERVER|R_EVENT))	return

		var/ok = 0
		switch(href_list["secretsfun"])
			if("sec_clothes")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","SC")
				for(var/obj/item/clothing/under/O in world)
					del(O)
				ok = 1
			if("sec_all_clothes")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","SAC")
				for(var/obj/item/clothing/O in world)
					del(O)
				ok = 1
			if("sec_classic1")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","SC1")
				for(var/obj/item/clothing/suit/fire/O in world)
					del(O)
				for(var/obj/structure/grille/O in world)
					del(O)
/*					for(var/obj/machinery/vehicle/pod/O in world)
					for(var/mob/M in src)
						M.loc = src.loc
						if (M.client)
							M.client.perspective = MOB_PERSPECTIVE
							M.client.eye = M
					del(O)
				ok = 1*/
			if("monkey")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","M")
				for(var/mob/living/carbon/human/H in mob_list)
					spawn(0)
						H.monkeyize()
				ok = 1
			if("corgi")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","M")
				for(var/mob/living/carbon/human/H in mob_list)
					spawn(0)
						H.corgize()
				ok = 1
			if("honksquad")
				if(usr.client.honksquad())
					feedback_inc("admin_secrets_fun_used",1)
					feedback_add_details("admin_secrets_fun_used","HONK")
			if("striketeam")
				if(usr.client.strike_team())
					feedback_inc("admin_secrets_fun_used",1)
					feedback_add_details("admin_secrets_fun_used","Strike")
			if("striketeam_syndicate")
				if(usr.client.syndicate_strike_team())
					feedback_inc("admin_secrets_fun_used",1)
					feedback_add_details("admin_secrets_fun_used","Strike")
			if("tripleAI")
				usr.client.triple_ai()
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","TriAI")
			if("gravity")
				if(!(ticker && ticker.mode))
					usr << "Please wait until the game starts!  Not sure how it will work otherwise."
					return
				gravity_is_on = !gravity_is_on
				for(var/area/A in world)
					A.gravitychange(gravity_is_on,A)
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","Grav")
				if(gravity_is_on)
					log_admin("[key_name(usr)] toggled gravity on.", 1)
					message_admins("\blue [key_name_admin(usr)] toggled gravity on.", 1)
					command_announcement.Announce("Gravity generators are again functioning within normal parameters. Sorry for any inconvenience.")
				else
					log_admin("[key_name(usr)] toggled gravity off.", 1)
					message_admins("\blue [key_name_admin(usr)] toggled gravity off.", 1)
					command_announcement.Announce("Feedback surge detected in mass-distributions systems. Artifical gravity has been disabled whilst the system reinitializes. Further failures may result in a gravitational collapse and formation of blackholes. Have a nice day.")

			if("power")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","P")
				log_admin("[key_name(usr)] made all areas powered", 1)
				message_admins("\blue [key_name_admin(usr)] made all areas powered", 1)
				power_restore()
			if("unpower")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","UP")
				log_admin("[key_name(usr)] made all areas unpowered", 1)
				message_admins("\blue [key_name_admin(usr)] made all areas unpowered", 1)
				power_failure()
			if("quickpower")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","QP")
				log_admin("[key_name(usr)] made all SMESs powered", 1)
				message_admins("\blue [key_name_admin(usr)] made all SMESs powered", 1)
				power_restore_quick()
			if("activateprison")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","AP")
				world << "\blue <B>Transit signature detected.</B>"
				world << "\blue <B>Incoming shuttle.</B>"
				/*
				var/A = locate(/area/shuttle_prison)
				for(var/atom/movable/AM as mob|obj in A)
					AM.z = 1
					AM.Move()
				*/
				message_admins("\blue [key_name_admin(usr)] sent the prison shuttle to the station.", 1)
			if("deactivateprison")
				/*
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","DP")
				var/A = locate(/area/shuttle_prison)
				for(var/atom/movable/AM as mob|obj in A)
					AM.z = 2
					AM.Move()
				*/
				message_admins("\blue [key_name_admin(usr)] sent the prison shuttle back.", 1)
			if("toggleprisonstatus")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","TPS")
				for(var/obj/machinery/computer/prison_shuttle/PS in world)
					PS.allowedtocall = !(PS.allowedtocall)
					message_admins("\blue [key_name_admin(usr)] toggled status of prison shuttle to [PS.allowedtocall].", 1)
			if("prisonwarp")
				if(!ticker)
					alert("The game hasn't started yet!", null, null, null, null, null)
					return
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","PW")
				message_admins("\blue [key_name_admin(usr)] teleported all players to the prison station.", 1)
				for(var/mob/living/carbon/human/H in mob_list)
					var/turf/loc = find_loc(H)
					var/security = 0
					if(!(loc.z in config.station_levels) || prisonwarped.Find(H))

//don't warp them if they aren't ready or are already there
						continue
					H.Paralyse(5)
					if(H.wear_id)
						var/obj/item/weapon/card/id/id = H.get_idcard()
						for(var/A in id.access)
							if(A == access_security)
								security++
					if(!security)
						//strip their stuff before they teleport into a cell :downs:
						for(var/obj/item/weapon/W in H)
							if(istype(W, /obj/item/organ/external))
								continue
								//don't strip organs
							H.unEquip(W)
							if (H.client)
								H.client.screen -= W
							if (W)
								W.loc = H.loc
								W.dropped(H)
								W.layer = initial(W.layer)
						//teleport person to cell
						H.loc = pick(prisonwarp)
						H.equip_to_slot_or_del(new /obj/item/clothing/under/color/orange(H), slot_w_uniform)
						H.equip_to_slot_or_del(new /obj/item/clothing/shoes/orange(H), slot_shoes)
					else
						//teleport security person
						H.loc = pick(prisonsecuritywarp)
					prisonwarped += H
			if("traitor_all")
				if(!ticker)
					alert("The game hasn't started yet!")
					return
				var/objective = sanitize(copytext(input("Enter an objective"),1,MAX_MESSAGE_LEN))
				if(!objective)
					return
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","TA([objective])")
				for(var/mob/living/carbon/human/H in player_list)
					if(H.stat == 2 || !H.client || !H.mind) continue
					if(is_special_character(H)) continue
					//traitorize(H, objective, 0)
					ticker.mode.traitors += H.mind
					H.mind.special_role = "traitor"
					var/datum/objective/new_objective = new
					new_objective.owner = H
					new_objective.explanation_text = objective
					H.mind.objectives += new_objective
					ticker.mode.greet_traitor(H.mind)
					//ticker.mode.forge_traitor_objectives(H.mind)
					ticker.mode.finalize_traitor(H.mind)
				for(var/mob/living/silicon/A in player_list)
					ticker.mode.traitors += A.mind
					A.mind.special_role = "traitor"
					var/datum/objective/new_objective = new
					new_objective.owner = A
					new_objective.explanation_text = objective
					A.mind.objectives += new_objective
					ticker.mode.greet_traitor(A.mind)
					ticker.mode.finalize_traitor(A.mind)
				message_admins("\blue [key_name_admin(usr)] used everyone is a traitor secret. Objective is [objective]", 1)
				log_admin("[key_name(usr)] used everyone is a traitor secret. Objective is [objective]")

			if("launchshuttle")
				if(!shuttle_controller) return // Something is very wrong, the shuttle controller has not been created.

				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","ShL")

				var/list/valid_shuttles = list()
				for (var/shuttle_tag in shuttle_controller.shuttles)
					if (istype(shuttle_controller.shuttles[shuttle_tag], /datum/shuttle/ferry))
						valid_shuttles += shuttle_tag

				var/shuttle_tag = input("Which shuttle do you want to launch?") as null|anything in valid_shuttles

				if (!shuttle_tag)
					return

				var/datum/shuttle/ferry/S = shuttle_controller.shuttles[shuttle_tag]
				if (S.can_launch())
					S.launch(usr)
					message_admins("\blue [key_name_admin(usr)] launched the [shuttle_tag] shuttle", 1)
					log_admin("[key_name(usr)] launched the [shuttle_tag] shuttle")
				else
					alert("The [shuttle_tag] shuttle cannot be launched at this time. It's probably busy.")

			if("forcelaunchshuttle")
				if(!shuttle_controller) return // Something is very wrong, the shuttle controller has not been created.

				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","ShFL")

				var/list/valid_shuttles = list()
				for (var/shuttle_tag in shuttle_controller.shuttles)
					if (istype(shuttle_controller.shuttles[shuttle_tag], /datum/shuttle/ferry))
						valid_shuttles += shuttle_tag

				var/shuttle_tag = input("Which shuttle's launch do you want to force?") as null|anything in valid_shuttles

				if (!shuttle_tag)
					return

				var/datum/shuttle/ferry/S = shuttle_controller.shuttles[shuttle_tag]
				if (S.can_force())
					S.force_launch(usr)
					message_admins("\blue [key_name_admin(usr)] has forced the [shuttle_tag] shuttle launch", 1)
					log_admin("[key_name(usr)] has forced the [shuttle_tag] shuttle launch")
				else
					alert("The [shuttle_tag] shuttle launch cannot be forced at this time. It's busy, or hasn't been launched yet.")

			if("jumpshuttle")
				if(!shuttle_controller) return // Something is very wrong, the shuttle controller has not been created.

				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","ShJ")

				var/shuttle_tag = input("Which shuttle do you want to jump?") as null|anything in shuttle_controller.shuttles
				if (!shuttle_tag) return

				var/datum/shuttle/S = shuttle_controller.shuttles[shuttle_tag]

				var/origin_area = input("Which area is the shuttle at now? (MAKE SURE THIS IS CORRECT OR THINGS WILL BREAK)") as null|area in world
				if (!origin_area) return

				var/destination_area = input("Which area is the shuttle at now? (MAKE SURE THIS IS CORRECT OR THINGS WILL BREAK)") as null|area in world
				if (!destination_area) return

				var/long_jump = alert("Is there a transition area for this jump?","", "Yes", "No")
				if (long_jump == "Yes")
					var/transition_area = input("Which area is the transition area? (MAKE SURE THIS IS CORRECT OR THINGS WILL BREAK)") as null|area in world
					if (!transition_area) return

					var/move_duration = input("How many seconds will this jump take?") as num

					S.long_jump(origin_area, destination_area, transition_area, move_duration)
					message_admins("\blue [key_name_admin(usr)] has initiated a jump from [origin_area] to [destination_area] lasting [move_duration] seconds for the [shuttle_tag] shuttle", 1)
					log_admin("[key_name_admin(usr)] has initiated a jump from [origin_area] to [destination_area] lasting [move_duration] seconds for the [shuttle_tag] shuttle")
				else
					S.short_jump(origin_area, destination_area)
					message_admins("\blue [key_name_admin(usr)] has initiated a jump from [origin_area] to [destination_area] for the [shuttle_tag] shuttle", 1)
					log_admin("[key_name_admin(usr)] has initiated a jump from [origin_area] to [destination_area] for the [shuttle_tag] shuttle")

			if("moveshuttle")

				if(!shuttle_controller) return // Something is very wrong, the shuttle controller has not been created.

				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","ShM")

				var/confirm = alert("This command directly moves a shuttle from one area to another. DO NOT USE THIS UNLESS YOU ARE DEBUGGING A SHUTTLE AND YOU KNOW WHAT YOU ARE DOING.", "Are you sure?", "Ok", "Cancel")
				if (confirm == "Cancel")
					return

				var/shuttle_tag = input("Which shuttle do you want to jump?") as null|anything in shuttle_controller.shuttles
				if (!shuttle_tag) return

				var/datum/shuttle/S = shuttle_controller.shuttles[shuttle_tag]

				var/origin_area = input("Which area is the shuttle at now? (MAKE SURE THIS IS CORRECT OR THINGS WILL BREAK)") as null|area in world
				if (!origin_area) return

				var/destination_area = input("Which area is the shuttle at now? (MAKE SURE THIS IS CORRECT OR THINGS WILL BREAK)") as null|area in world
				if (!destination_area) return

				S.move(origin_area, destination_area)
				message_admins("\blue [key_name_admin(usr)] moved the [shuttle_tag] shuttle", 1)
				log_admin("[key_name(usr)] moved the [shuttle_tag] shuttle")

			if("togglebombcap")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","BC")
				switch(MAX_EXPLOSION_RANGE)
					if(14)	MAX_EXPLOSION_RANGE = 16
					if(16)	MAX_EXPLOSION_RANGE = 20
					if(20)	MAX_EXPLOSION_RANGE = 28
					if(28)	MAX_EXPLOSION_RANGE = 56
					if(56)	MAX_EXPLOSION_RANGE = 128
					else	MAX_EXPLOSION_RANGE = 14
				var/range_dev = MAX_EXPLOSION_RANGE *0.25
				var/range_high = MAX_EXPLOSION_RANGE *0.5
				var/range_low = MAX_EXPLOSION_RANGE
				message_admins("\red <b> [key_name_admin(usr)] changed the bomb cap to [range_dev], [range_high], [range_low]</b>", 1)
				log_admin("[key_name_admin(usr)] changed the bomb cap to [MAX_EXPLOSION_RANGE]")

			if("flicklights")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","FL")
				while(!usr.stat)
//knock yourself out to stop the ghosts
					for(var/mob/M in player_list)
						if(M.stat != 2 && prob(25))
							var/area/AffectedArea = get_area(M)
							if(AffectedArea.name != "Space" && AffectedArea.name != "Engine Walls" && AffectedArea.name != "Chemical Lab Test Chamber" && AffectedArea.name != "Escape Shuttle" && AffectedArea.name != "Arrival Area" && AffectedArea.name != "Arrival Shuttle" && AffectedArea.name != "start area" && AffectedArea.name != "Engine Combustion Chamber")
								AffectedArea.power_light = 0
								AffectedArea.power_change()
								spawn(rand(55,185))
									AffectedArea.power_light = 1
									AffectedArea.power_change()
								var/Message = rand(1,4)
								switch(Message)
									if(1)
										M.show_message(text("\blue You shudder as if cold..."), 1)
									if(2)
										M.show_message(text("\blue You feel something gliding across your back..."), 1)
									if(3)
										M.show_message(text("\blue Your eyes twitch, you feel like something you can't see is here..."), 1)
									if(4)
										M.show_message(text("\blue You notice something moving out of the corner of your eye, but nothing is there..."), 1)
								for(var/obj/W in orange(5,M))
									if(prob(25) && !W.anchored)
										step_rand(W)
					sleep(rand(100,1000))
				for(var/mob/M in player_list)
					if(M.stat != 2)
						M.show_message(text("\blue The chilling wind suddenly stops..."), 1)
/*				if("shockwave")
				ok = 1
				world << "\red <B><big>ALERT: STATION STRESS CRITICAL</big></B>"
				sleep(60)
				world << "\red <B><big>ALERT: STATION STRESS CRITICAL. TOLERABLE LEVELS EXCEEDED!</big></B>"
				sleep(80)
				world << "\red <B><big>ALERT: STATION STRUCTURAL STRESS CRITICAL. SAFETY MECHANISMS FAILED!</big></B>"
				sleep(40)
				for(var/mob/M in world)
					shake_camera(M, 400, 1)
				for(var/obj/structure/window/W in world)
					spawn(0)
						sleep(rand(10,400))
						W.ex_act(rand(2,1))
				for(var/obj/structure/grille/G in world)
					spawn(0)
						sleep(rand(20,400))
						G.ex_act(rand(2,1))
				for(var/obj/machinery/door/D in world)
					spawn(0)
						sleep(rand(20,400))
						D.ex_act(rand(2,1))
				for(var/turf/station/floor/Floor in world)
					spawn(0)
						sleep(rand(30,400))
						Floor.ex_act(rand(2,1))
				for(var/obj/structure/cable/Cable in world)
					spawn(0)
						sleep(rand(30,400))
						Cable.ex_act(rand(2,1))
				for(var/obj/structure/closet/Closet in world)
					spawn(0)
						sleep(rand(30,400))
						Closet.ex_act(rand(2,1))
				for(var/obj/machinery/Machinery in world)
					spawn(0)
						sleep(rand(30,400))
						Machinery.ex_act(rand(1,3))
				for(var/turf/station/wall/Wall in world)
					spawn(0)
						sleep(rand(30,400))
						Wall.ex_act(rand(2,1)) */
			if("lightout")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","LO")
				message_admins("[key_name_admin(usr)] has broke a lot of lights", 1)
				lightsout(1,2)
			if("blackout")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","BO")
				message_admins("[key_name_admin(usr)] broke all lights", 1)
				lightsout(0,0)
			if("whiteout")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","WO")
				for(var/obj/machinery/light/L in world)
					L.fix()
				message_admins("[key_name_admin(usr)] fixed all lights", 1)
			if("floorlava")
				if(floorIsLava)
					usr << "The floor is lava already."
					return
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","LF")

				//Options
				var/length = input(usr, "How long will the lava last? (in seconds)", "Length", 180) as num
				length = min(abs(length), 1200)

				var/damage = input(usr, "How deadly will the lava be?", "Damage", 2) as num
				damage = min(abs(damage), 100)

				var/sure = alert(usr, "Are you sure you want to do this?", "Confirmation", "YES!", "Nah")
				if(sure == "Nah")
					return
				floorIsLava = 1

				message_admins("[key_name_admin(usr)] made the floor LAVA! It'll last [length] seconds and it will deal [damage] damage to everyone.", 1)

				for(var/turf/simulated/floor/F in world)
					if((F.z in config.station_levels))
						F.name = "lava"
						F.desc = "The floor is LAVA!"
						F.overlays += "lava"
						F.lava = 1

				spawn(0)
					for(var/i = i, i < length, i++) // 180 = 3 minutes
						if(damage)
							for(var/mob/living/carbon/L in living_mob_list)
								if(istype(L.loc, /turf/simulated/floor)) // Are they on LAVA?!
									var/turf/simulated/floor/F = L.loc
									if(F.lava)
										var/safe = 0
										for(var/obj/structure/O in F.contents)
											if(O.level > F.level && !istype(O, /obj/structure/window)) // Something to stand on and it isn't under the floor!
												safe = 1
												break
										if(!safe)
											L.adjustFireLoss(damage)


						sleep(10)

					for(var/turf/simulated/floor/F in world) // Reset everything.
						if((F.z in config.station_levels))
							F.name = initial(F.name)
							F.desc = initial(F.desc)
							F.overlays.Cut()
							F.lava = 0
							F.update_icon()
					floorIsLava = 0
				return
			if("retardify")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","RET")
				for(var/mob/living/carbon/human/H in player_list)
					H << "\red <B>You suddenly feel stupid.</B>"
					H.setBrainLoss(60)
				message_admins("[key_name_admin(usr)] made everybody retarded")
			if("fakeguns")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","FG")
				for(var/obj/item/W in world)
					if(istype(W, /obj/item/clothing) || istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/weapon/disk) || istype(W, /obj/item/weapon/tank))
						continue
					W.icon = 'icons/obj/gun.dmi'
					W.icon_state = "revolver"
					W.item_state = "gun"
				message_admins("[key_name_admin(usr)] made every item look like a gun")
			if("schoolgirl")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","SG")
				for(var/obj/item/clothing/under/W in world)
					W.icon_state = "schoolgirl"
					W.item_state = "w_suit"
					W._color = "schoolgirl"
				message_admins("[key_name_admin(usr)] activated Japanese Animes mode")
				world << sound('sound/AI/animes.ogg')
			if("eagles")//SCRAW
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","EgL")
				for(var/obj/machinery/door/airlock/W in world)
					if((W.z in config.station_levels) && !istype(get_area(W), /area/bridge) && !istype(get_area(W), /area/crew_quarters) && !istype(get_area(W), /area/security/prison))
						W.req_access = list()
				message_admins("[key_name_admin(usr)] activated Egalitarian Station mode")
				command_announcement.Announce("Centcomm airlock control override activated. Please take this time to get acquainted with your coworkers.", new_sound = 'sound/AI/commandreport.ogg')
			if("onlyone")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","OO")
				usr.client.only_one()
//				message_admins("[key_name_admin(usr)] has triggered HIGHLANDER")
			if("onlyoneteam")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","OOT")
				usr.client.only_one_team()
//				message_admins("[key_name_admin(usr)] has triggered ")
			if("rolldice")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","ROL")
				usr.client.roll_dices()
			if("guns")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","SG")
				usr.rightandwrong(0)
			if("magic")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","SM")
				usr.rightandwrong(1)
			if("tdomereset")
				var/delete_mobs = alert("Clear all mobs?","Confirm","Yes","No","Cancel")
				if(delete_mobs == "Cancel")
					return

				var/area/thunderdome = locate(/area/tdome/arena)
				if(delete_mobs == "Yes")
					for(var/mob/living/mob in thunderdome)
						qdel(mob) //Clear mobs
				for(var/obj/obj in thunderdome)
					if(!istype(obj,/obj/machinery/camera))
						qdel(obj) //Clear objects

				var/area/template = locate(/area/tdome/arena_source)
				template.copy_contents_to(thunderdome)

				log_admin("[key_name(usr)] reset the thunderdome to default with delete_mobs==[delete_mobs].", 1)
				message_admins("<span class='adminnotice'>[key_name_admin(usr)] reset the thunderdome to default with delete_mobs==[delete_mobs].</span>")

			if("tdomestart")
				var/confirmation = alert("Start a Thunderdome match?","Confirm","Yes","No")
				if(confirmation == "No")
					return
				if(makeThunderdomeTeams())
					log_admin("[key_name(usr)] started a Thunderdome match!", 1)
					message_admins("<span class='adminnotice'>[key_name_admin(usr)] has started a Thunderdome match!</span>")
				else
					log_admin("[key_name(usr)] attempted to start a Thunderdome match, but no ghosts signed up.", 1)
					message_admins("<span class='adminnotice'>[key_name_admin(usr)] tried starting a Thunderdome match, but no ghosts signed up.</span>")
			if("securitylevel0")
				set_security_level(0)
				message_admins("\blue [key_name_admin(usr)] change security level to Green.", 1)
			if("securitylevel1")
				set_security_level(1)
				message_admins("\blue [key_name_admin(usr)] change security level to Blue.", 1)
			if("securitylevel2")
				set_security_level(2)
				message_admins("\blue [key_name_admin(usr)] change security level to Red.", 1)
			if("securitylevel3")
				set_security_level(3)
				message_admins("\blue [key_name_admin(usr)] change security level to Gamma.", 1)
			if("securitylevel4")
				set_security_level(4)
				message_admins("\blue [key_name_admin(usr)] change security level to Epsilon.", 1)
			if("securitylevel5")
				set_security_level(5)
				message_admins("\blue [key_name_admin(usr)] change security level to Delta.", 1)
		if(usr)
			log_admin("[key_name(usr)] used secret [href_list["secretsfun"]]")
			if (ok)
				world << text("<B>A secret has been activated by []!</B>", usr.key)

	else if(href_list["secretsadmin"])
		if(!check_rights(R_ADMIN))	return

		var/ok = 0
		switch(href_list["secretsadmin"])
			if("clear_bombs")
				//I do nothing
			if("list_bombers")
				var/dat = "<B>Bombing List<HR>"
				for(var/l in bombers)
					dat += text("[l]<BR>")
				usr << browse(dat, "window=bombers")
			if("list_signalers")
				var/dat = "<B>Showing last [length(lastsignalers)] signalers.</B><HR>"
				for(var/sig in lastsignalers)
					dat += "[sig]<BR>"
				usr << browse(dat, "window=lastsignalers;size=800x500")
			if("list_lawchanges")
				var/dat = "<B>Showing last [length(lawchanges)] law changes.</B><HR>"
				for(var/sig in lawchanges)
					dat += "[sig]<BR>"
				usr << browse(dat, "window=lawchanges;size=800x500")
			if("list_job_debug")
				var/dat = "<B>Job Debug info.</B><HR>"
				if(job_master)
					for(var/line in job_master.job_debug)
						dat += "[line]<BR>"
					dat+= "*******<BR><BR>"
					for(var/datum/job/job in job_master.occupations)
						if(!job)	continue
						dat += "job: [job.title], current_positions: [job.current_positions], total_positions: [job.total_positions] <BR>"
					usr << browse(dat, "window=jobdebug;size=600x500")
			if("showailaws")
				output_ai_laws()
			if("showgm")
				if(!ticker)
					alert("The game hasn't started yet!")
				else if (ticker.mode)
					alert("The game mode is [ticker.mode.name]")
				else alert("For some reason there's a ticker, but not a game mode")
			if("manifest")
				var/dat = "<B>Showing Crew Manifest.</B><HR>"
				dat += "<table cellspacing=5><tr><th>Name</th><th>Position</th></tr>"
				for(var/mob/living/carbon/human/H in mob_list)
					if(H.ckey)
						dat += text("<tr><td>[]</td><td>[]</td></tr>", H.name, H.get_assignment())
				dat += "</table>"
				usr << browse(dat, "window=manifest;size=440x410")
			if("check_antagonist")
				check_antagonists()
			if("DNA")
				var/dat = "<B>Showing DNA from blood.</B><HR>"
				dat += "<table cellspacing=5><tr><th>Name</th><th>DNA</th><th>Blood Type</th></tr>"
				for(var/mob/living/carbon/human/H in mob_list)
					if(H.dna && H.ckey)
						dat += "<tr><td>[H]</td><td>[H.dna.unique_enzymes]</td><td>[H.b_type]</td></tr>"
				dat += "</table>"
				usr << browse(dat, "window=DNA;size=440x410")
			if("fingerprints")
				var/dat = "<B>Showing Fingerprints.</B><HR>"
				dat += "<table cellspacing=5><tr><th>Name</th><th>Fingerprints</th></tr>"
				for(var/mob/living/carbon/human/H in mob_list)
					if(H.ckey)
						if(H.dna && H.dna.uni_identity)
							dat += "<tr><td>[H]</td><td>[md5(H.dna.uni_identity)]</td></tr>"
						else if(H.dna && !H.dna.uni_identity)
							dat += "<tr><td>[H]</td><td>H.dna.uni_identity = null</td></tr>"
						else if(!H.dna)
							dat += "<tr><td>[H]</td><td>H.dna = null</td></tr>"
				dat += "</table>"
				usr << browse(dat, "window=fingerprints;size=440x410")
			else
		if (usr)
			log_admin("[key_name(usr)] used secret [href_list["secretsadmin"]]")
			if (ok)
				world << text("<B>A secret has been activated by []!</B>", usr.key)

	else if(href_list["secretscoder"])
		if(!check_rights(R_DEBUG))	return

		switch(href_list["secretscoder"])
			if("spawn_objects")
				var/dat = "<B>Admin Log<HR></B>"
				for(var/l in admin_log)
					dat += "<li>[l]</li>"
				if(!admin_log.len)
					dat += "No-one has done anything this round!"
				usr << browse(dat, "window=admin_log")
			if("maint_access_brig")
				for(var/obj/machinery/door/airlock/maintenance/M in world)
					if (access_maint_tunnels in M.req_access)
						M.req_access = list(access_brig)
				message_admins("[key_name_admin(usr)] made all maint doors brig access-only.")
			if("maint_access_engiebrig")
				for(var/obj/machinery/door/airlock/maintenance/M in world)
					if (access_maint_tunnels in M.req_access)
						M.req_access = list()
						M.req_one_access = list(access_brig,access_engine)
				message_admins("[key_name_admin(usr)] made all maint doors engineering and brig access-only.")
			if("infinite_sec")
				var/datum/job/J = job_master.GetJob("Security Officer")
				if(!J) return
				J.total_positions = -1
				J.spawn_positions = -1
				message_admins("[key_name_admin(usr)] has removed the cap on security officers.")

	else if(href_list["ac_view_wanted"])            //Admin newscaster Topic() stuff be here
		src.admincaster_screen = 18                 //The ac_ prefix before the hrefs stands for AdminCaster.
		src.access_news_network()

	else if(href_list["ac_set_channel_name"])
		src.admincaster_feed_channel.channel_name = strip_html_simple(input(usr, "Provide a Feed Channel Name", "Network Channel Handler", ""))
		while (findtext(src.admincaster_feed_channel.channel_name," ") == 1)
			src.admincaster_feed_channel.channel_name = copytext(src.admincaster_feed_channel.channel_name,2,lentext(src.admincaster_feed_channel.channel_name)+1)
		src.access_news_network()

	else if(href_list["ac_set_channel_lock"])
		src.admincaster_feed_channel.locked = !src.admincaster_feed_channel.locked
		src.access_news_network()

	else if(href_list["ac_submit_new_channel"])
		var/check = 0
		for(var/datum/feed_channel/FC in news_network.network_channels)
			if(FC.channel_name == src.admincaster_feed_channel.channel_name)
				check = 1
				break
		if(src.admincaster_feed_channel.channel_name == "" || src.admincaster_feed_channel.channel_name == "\[REDACTED\]" || check )
			src.admincaster_screen=7
		else
			var/choice = alert("Please confirm Feed channel creation","Network Channel Handler","Confirm","Cancel")
			if(choice=="Confirm")
				var/datum/feed_channel/newChannel = new /datum/feed_channel
				newChannel.channel_name = src.admincaster_feed_channel.channel_name
				newChannel.author = src.admincaster_signature
				newChannel.locked = src.admincaster_feed_channel.locked
				newChannel.is_admin_channel = 1
				feedback_inc("newscaster_channels",1)
				news_network.network_channels += newChannel                        //Adding channel to the global network
				log_admin("[key_name_admin(usr)] created command feed channel: [src.admincaster_feed_channel.channel_name]!")
				src.admincaster_screen=5
		src.access_news_network()

	else if(href_list["ac_set_channel_receiving"])
		var/list/available_channels = list()
		for(var/datum/feed_channel/F in news_network.network_channels)
			available_channels += F.channel_name
		src.admincaster_feed_channel.channel_name = adminscrub(input(usr, "Choose receiving Feed Channel", "Network Channel Handler") in available_channels )
		src.access_news_network()

	else if(href_list["ac_set_new_message"])
		src.admincaster_feed_message.body = adminscrub(input(usr, "Write your Feed story", "Network Channel Handler", ""))
		while (findtext(src.admincaster_feed_message.body," ") == 1)
			src.admincaster_feed_message.body = copytext(src.admincaster_feed_message.body,2,lentext(src.admincaster_feed_message.body)+1)
		src.access_news_network()

	else if(href_list["ac_submit_new_message"])
		if(src.admincaster_feed_message.body =="" || src.admincaster_feed_message.body =="\[REDACTED\]" || src.admincaster_feed_channel.channel_name == "" )
			src.admincaster_screen = 6
		else
			var/datum/feed_message/newMsg = new /datum/feed_message
			newMsg.author = src.admincaster_signature
			newMsg.body = src.admincaster_feed_message.body
			newMsg.is_admin_message = 1
			feedback_inc("newscaster_stories",1)
			for(var/datum/feed_channel/FC in news_network.network_channels)
				if(FC.channel_name == src.admincaster_feed_channel.channel_name)
					FC.messages += newMsg                  //Adding message to the network's appropriate feed_channel
					break
			src.admincaster_screen=4

		for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
			NEWSCASTER.newsAlert(src.admincaster_feed_channel.channel_name)

		log_admin("[key_name_admin(usr)] submitted a feed story to channel: [src.admincaster_feed_channel.channel_name]!")
		src.access_news_network()

	else if(href_list["ac_create_channel"])
		src.admincaster_screen=2
		src.access_news_network()

	else if(href_list["ac_create_feed_story"])
		src.admincaster_screen=3
		src.access_news_network()

	else if(href_list["ac_menu_censor_story"])
		src.admincaster_screen=10
		src.access_news_network()

	else if(href_list["ac_menu_censor_channel"])
		src.admincaster_screen=11
		src.access_news_network()

	else if(href_list["ac_menu_wanted"])
		var/already_wanted = 0
		if(news_network.wanted_issue)
			already_wanted = 1

		if(already_wanted)
			src.admincaster_feed_message.author = news_network.wanted_issue.author
			src.admincaster_feed_message.body = news_network.wanted_issue.body
		src.admincaster_screen = 14
		src.access_news_network()

	else if(href_list["ac_set_wanted_name"])
		src.admincaster_feed_message.author = adminscrub(input(usr, "Provide the name of the Wanted person", "Network Security Handler", ""))
		while (findtext(src.admincaster_feed_message.author," ") == 1)
			src.admincaster_feed_message.author = copytext(admincaster_feed_message.author,2,lentext(admincaster_feed_message.author)+1)
		src.access_news_network()

	else if(href_list["ac_set_wanted_desc"])
		src.admincaster_feed_message.body = adminscrub(input(usr, "Provide the a description of the Wanted person and any other details you deem important", "Network Security Handler", ""))
		while (findtext(src.admincaster_feed_message.body," ") == 1)
			src.admincaster_feed_message.body = copytext(src.admincaster_feed_message.body,2,lentext(src.admincaster_feed_message.body)+1)
		src.access_news_network()

	else if(href_list["ac_submit_wanted"])
		var/input_param = text2num(href_list["ac_submit_wanted"])
		if(src.admincaster_feed_message.author == "" || src.admincaster_feed_message.body == "")
			src.admincaster_screen = 16
		else
			var/choice = alert("Please confirm Wanted Issue [(input_param==1) ? ("creation.") : ("edit.")]","Network Security Handler","Confirm","Cancel")
			if(choice=="Confirm")
				if(input_param==1)          //If input_param == 1 we're submitting a new wanted issue. At 2 we're just editing an existing one. See the else below
					var/datum/feed_message/WANTED = new /datum/feed_message
					WANTED.author = src.admincaster_feed_message.author               //Wanted name
					WANTED.body = src.admincaster_feed_message.body                   //Wanted desc
					WANTED.backup_author = src.admincaster_signature                  //Submitted by
					WANTED.is_admin_message = 1
					news_network.wanted_issue = WANTED
					for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
						NEWSCASTER.newsAlert()
						NEWSCASTER.update_icon()
					src.admincaster_screen = 15
				else
					news_network.wanted_issue.author = src.admincaster_feed_message.author
					news_network.wanted_issue.body = src.admincaster_feed_message.body
					news_network.wanted_issue.backup_author = src.admincaster_feed_message.backup_author
					src.admincaster_screen = 19
				log_admin("[key_name_admin(usr)] issued a Station-wide Wanted Notification for [src.admincaster_feed_message.author]!")
		src.access_news_network()

	else if(href_list["ac_cancel_wanted"])
		var/choice = alert("Please confirm Wanted Issue removal","Network Security Handler","Confirm","Cancel")
		if(choice=="Confirm")
			news_network.wanted_issue = null
			for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
				NEWSCASTER.update_icon()
			src.admincaster_screen=17
		src.access_news_network()

	else if(href_list["ac_censor_channel_author"])
		var/datum/feed_channel/FC = locate(href_list["ac_censor_channel_author"])
		if(FC.author != "<B>\[REDACTED\]</B>")
			FC.backup_author = FC.author
			FC.author = "<B>\[REDACTED\]</B>"
		else
			FC.author = FC.backup_author
		src.access_news_network()

	else if(href_list["ac_censor_channel_story_author"])
		var/datum/feed_message/MSG = locate(href_list["ac_censor_channel_story_author"])
		if(MSG.author != "<B>\[REDACTED\]</B>")
			MSG.backup_author = MSG.author
			MSG.author = "<B>\[REDACTED\]</B>"
		else
			MSG.author = MSG.backup_author
		src.access_news_network()

	else if(href_list["ac_censor_channel_story_body"])
		var/datum/feed_message/MSG = locate(href_list["ac_censor_channel_story_body"])
		if(MSG.body != "<B>\[REDACTED\]</B>")
			MSG.backup_body = MSG.body
			MSG.body = "<B>\[REDACTED\]</B>"
		else
			MSG.body = MSG.backup_body
		src.access_news_network()

	else if(href_list["ac_pick_d_notice"])
		var/datum/feed_channel/FC = locate(href_list["ac_pick_d_notice"])
		src.admincaster_feed_channel = FC
		src.admincaster_screen=13
		src.access_news_network()

	else if(href_list["ac_toggle_d_notice"])
		var/datum/feed_channel/FC = locate(href_list["ac_toggle_d_notice"])
		FC.censored = !FC.censored
		src.access_news_network()

	else if(href_list["ac_view"])
		src.admincaster_screen=1
		src.access_news_network()

	else if(href_list["ac_setScreen"]) //Brings us to the main menu and resets all fields~
		src.admincaster_screen = text2num(href_list["ac_setScreen"])
		if (src.admincaster_screen == 0)
			if(src.admincaster_feed_channel)
				src.admincaster_feed_channel = new /datum/feed_channel
			if(src.admincaster_feed_message)
				src.admincaster_feed_message = new /datum/feed_message
		src.access_news_network()

	else if(href_list["ac_show_channel"])
		var/datum/feed_channel/FC = locate(href_list["ac_show_channel"])
		src.admincaster_feed_channel = FC
		src.admincaster_screen = 9
		src.access_news_network()

	else if(href_list["ac_pick_censor_channel"])
		var/datum/feed_channel/FC = locate(href_list["ac_pick_censor_channel"])
		src.admincaster_feed_channel = FC
		src.admincaster_screen = 12
		src.access_news_network()

	else if(href_list["ac_refresh"])
		src.access_news_network()

	else if(href_list["ac_set_signature"])
		src.admincaster_signature = adminscrub(input(usr, "Provide your desired signature", "Network Identity Handler", ""))
		src.access_news_network()

	if(href_list["add_player_info"])
		var/key = href_list["add_player_info"]
		var/add = input("Add Player Info") as null|text
		if(!add) return

		notes_add(key,add,usr)
		show_player_info(key)

	if(href_list["remove_player_info"])
		var/key = href_list["remove_player_info"]
		var/index = text2num(href_list["remove_index"])

		notes_del(key, index)
		show_player_info(key)

	if(href_list["notes"])
		var/ckey = href_list["ckey"]
		if(!ckey)
			var/mob/M = locate(href_list["mob"])
			if(ismob(M))
				ckey = M.ckey

		switch(href_list["notes"])
			if("show")
				show_player_info(ckey)
			if("list")
				PlayerNotesPage(text2num(href_list["index"]))
		return

	if(href_list["secretsmenu"])
		switch(href_list["secretsmenu"])
			if("tab")
				current_tab = text2num(href_list["tab"])
				Secrets(usr)
				return 1

/proc/admin_jump_link(var/atom/target, var/source)
	if(!target) return
	// The way admin jump links handle their src is weirdly inconsistent...
	if(istype(source, /datum/admins))
		source = "src=\ref[source]"
	else
		source = "_src_=holder"

	if(isAI(target)) // AI core/eye follow links
		var/mob/living/silicon/ai/A = target
		. = "<A HREF='?[source];adminplayerobservejump=\ref[target]'>JMP</A>"
		if(A.client && A.eyeobj) // No point following clientless AI eyes
			. += "|<A HREF='?[source];adminplayerobservejump=\ref[A.eyeobj]'>EYE</A>"
		return
	else if(istype(target, /mob/dead/observer))
		var/mob/dead/observer/O = target
		. = "<A HREF='?[source];adminplayerobservejump=\ref[target]'>JMP</A>"
		if(O.mind && O.mind.current)
			. += "|<A HREF='?[source];adminplayerobservejump=\ref[O.mind.current]'>BDY</A>"
		return
	else
		return "<A HREF='?[source];adminplayerobservejump=\ref[target]'>JMP</A>"
