//Changed var/air_master.current_cycle to SSair.times_fired



/obj/vore_preferences //When you click the "into" button on a vore organ in the Vore panel
	proc/BuildTransfer()
		var/dat= ""
		dat += "<BR>"
		dat += "<h2>Dispense</h2>"
		var/datum/vore_organ/VO=GetOrgan(tab_mod)
		dat += "<b>Currently dispensing [VO.milk_type]</b><BR>" // Shows what you're dispensing
		dat += "Generic: "
		dat += "<a href='?src=\ref[src];preference=dispense;organ=[tab_mod];amount=5;name=null'>5</a>" //How much you wanna dispense
		dat += "<a href='?src=\ref[src];preference=dispense;organ=[tab_mod];amount=10;name=null'>10</a>" // 10 units
		dat += "<a href='?src=\ref[src];preference=dispense;organ=[tab_mod];amount=15;name=null'>15</a>" // 15 units
		dat += "<a href='?src=\ref[src];preference=dispense;organ=[tab_mod];amount=20;name=null'>20</a>" // 20 units
		dat += "<BR>"
		if(tab_mod=="cock") //If this is the cock menu
			VO.milk_list.Add(VO.owner.vore_balls_datum.milk_list) //Vore owner's milk list should add balls into the milk. AKA balls = cock
			VO.owner.vore_balls_datum.milk_list=new/list()
		for(var/T in VO.milk_list) // I'm unsure on what this is, but it displays anything located in the milk list which is generated in the lines of code above.
			dat += "[T]: "
			dat += "<a href='?src=\ref[src];preference=dispense;organ=[tab_mod];amount=5;name=[T]'>5</a>"
			dat += "<a href='?src=\ref[src];preference=dispense;organ=[tab_mod];amount=10;name=[T]'>10</a>"
			dat += "<a href='?src=\ref[src];preference=dispense;organ=[tab_mod];amount=15;name=[T]'>15</a>"
			dat += "<a href='?src=\ref[src];preference=dispense;organ=[tab_mod];amount=20;name=[T]'>20</a>"
			dat += " ([VO.milk_list[T]["count"]] left)<BR>"
		dat += "<BR>"
		dat += "Transferring people from person to person coming soon.<BR>"
		return dat


/datum/vore_organ
	proc/dispense(var/amount=5,var/name=null) //Dispense is the proc defined.
		if(!milk_type)return //If milk is null, return, you can't use this proc.

		if(name=="null")name=null

		var/obj/item/weapon/reagent_containers/RC=null

		if(!owner.get_active_hand()) //If there isnt anything in their hand
			owner<<"There's nothing in your active hand."
			return

		if(!istype(owner.get_active_hand(), /obj/item/weapon/reagent_containers)) //if it isnt a reagent container.
			owner<<"You can't put [milk_type] in [owner.get_active_hand()]!"
			return

		RC=owner.get_active_hand()

		if(!RC||!istype(RC, /obj/item/weapon/reagent_containers))return

		if(!(RC.flags&OPENCONTAINER)) //If the container does not have flags which contain "OPENCONTAINER"
			owner<<"You can't put [milk_type] in [owner.get_active_hand()]!"
			return //No milk for you!

		if(RC.reagents.total_volume >= RC.reagents.maximum_volume) // If the container they wanted to fill is full do this
			owner<<"[owner.get_active_hand()] is full!"
			return //Too full

		amount=min(RC.reagents.maximum_volume-RC.reagents.total_volume,amount) //Getting the amount in the container
		var/list/data=new/list() //New data list

		if(name) //Remove the amount of liquid from the organ
			amount=min(amount,milk_list[name]["count"])
			milk_list[name]["count"]=milk_list[name]["count"]-amount
			data=milk_list[name]["data"]
			if(milk_list[name]["count"]<=0)
				milk_list.Remove(name)

		if(amount>0) //Checks to see if there is milk in the organ.
			if(last_release>SSair.times_fired-amount||owner.stat==2)return //Cannot spam it.

			last_release=SSair.times_fired

			data["adjective"]=kpcode_get_adjective(owner)

			data["type"]=kpcode_get_generic(owner)

			//var/ownr_dna=null

			if(istype(owner,/mob/living/carbon)) //If it's a carbon releasing, add owners DNA to data
				data["donor_DNA"]=owner:dna
				//ownr_dna=owner:dna

			RC.reagents.add_reagent(milk_type, amount, data)//list("digested"=name,"donor_DNA"=ownr_dna))

			if(milk_type=="milk")
				owner.visible_message("<span class='notice'>[owner] milks their tits into [RC].</span>")

			if(milk_type=="semen")
				owner.visible_message("<span class='notice'>[owner] jacks off into [RC].</span>")

			if(milk_type=="femjuice")
				owner.visible_message("<span class='notice'>[owner] masturbates their vagina over [RC].</span>")

			playsound(owner.get_top_level_mob(), 'sound/items/drink.ogg', 50, 1)