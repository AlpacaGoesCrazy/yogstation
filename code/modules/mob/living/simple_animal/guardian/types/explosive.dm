//Bomb
/mob/living/simple_animal/hostile/guardian/bomb
	melee_damage_lower = 15
	melee_damage_upper = 15
	damage_coeff = list(BRUTE = 0.6, BURN = 0.6, TOX = 0.6, CLONE = 0.6, STAMINA = 0, OXY = 0.6)
	range = 13
	playstyle_string = "<span class='holoparasite'>As an <b>explosive</b> type, you have moderate close combat abilities, may explosively teleport targets on attack, and are capable of converting nearby items and objects into disguised bombs via alt click.</span>"
	magic_fluff_string = "<span class='holoparasite'>..And draw the Scientist, master of explosive death.</span>"
	tech_fluff_string = "<span class='holoparasite'>Boot sequence complete. Explosive modules active. Holoparasite swarm online.</span>"
	carp_fluff_string = "<span class='holoparasite'>CARP CARP CARP! Caught one! It's an explosive carp! Boom goes the fishy.</span>"
	var/bomb_cooldown = 0

/mob/living/simple_animal/hostile/guardian/bomb/Stat()
	..()
	if(statpanel("Status"))
		if(bomb_cooldown >= world.time)
			stat(null, "Bomb Cooldown Remaining: [max(round((bomb_cooldown - world.time)*0.1, 0.1), 0)] seconds")

/mob/living/simple_animal/hostile/guardian/bomb/AttackingTarget()
	if(..())
		if(prob(40))
			if(isliving(target))
				var/mob/living/M = target
				if(!M.anchored && M != summoner && !hasmatchingsummoner(M))
					PoolOrNew(/obj/effect/overlay/temp/guardian/phase/out, get_turf(M))
					do_teleport(M, M, 10)
					for(var/mob/living/L in range(1, M))
						if(hasmatchingsummoner(L)) //if the summoner matches don't hurt them
							continue
						if(L != src && L != summoner)
							L.apply_damage(15, BRUTE)
					PoolOrNew(/obj/effect/overlay/temp/explosion, get_turf(M))
					playsound(get_turf(M),'sound/effects/Explosion2.ogg', 200, 1)

/mob/living/simple_animal/hostile/guardian/bomb/AltClickOn(atom/movable/A)
	if(!istype(A))
		return
	if(src.loc == summoner)
		to_chat(src, "<span class='danger'><B>You must be manifested to create bombs!</span></B>")
		return
	if(istype(A, /obj/))
		if(bomb_cooldown <= world.time && !stat)
			var/obj/item/weapon/guardian_bomb/B = new /obj/item/weapon/guardian_bomb(get_turf(A))
			to_chat(src, "<span class='danger'><B>Success! Bomb armed!</span></B>")
			bomb_cooldown = world.time + 300
			B.spawner = src
			B.disguise(A)
		else
			to_chat(src, "<span class='danger'><B>Your powers are on cooldown! You must wait 30 seconds between bombs.</span></B>")

/obj/item/weapon/guardian_bomb
	name = "bomb"
	desc = "You shouldn't be seeing this!"
	var/obj/stored_obj
	var/mob/living/simple_animal/hostile/guardian/spawner


/obj/item/weapon/guardian_bomb/proc/disguise(var/obj/A)
	A.loc = src
	stored_obj = A
	opacity = A.opacity
	anchored = A.anchored
	density = A.density
	appearance = A.appearance
	addtimer(src,"vanish", 1000)

/obj/item/weapon/guardian_bomb/proc/vanish(var/obj/A)
	stored_obj.loc = get_turf(src.loc)
	to_chat(spawner, "<span class='danger'><B>Failure! Your trap didn't catch anyone this time.</span></B>")
	qdel(src)

/obj/item/weapon/guardian_bomb/proc/detonate(var/mob/living/user)
	to_chat(user, "<span class='danger'><B>[src] was boobytrapped!</span></B>")
	to_chat(spawner, "<span class='danger'><B>Success! Your trap caught [user]</span></B>")
	stored_obj.loc = get_turf(src.loc)
	playsound(get_turf(src),'sound/effects/Explosion2.ogg', 200, 1)
	user.ex_act(2)
	qdel(src)

/obj/item/weapon/guardian_bomb/Bumped(mob/user)
	if(isliving(user) && user != spawner && user != spawner.summoner && !spawner.hasmatchingsummoner(user))
		detonate(user)
	else
		..()

/obj/item/weapon/guardian_bomb/attackby(obj/item/C, mob/user)
	if(isliving(user) && user != spawner && user != spawner.summoner && !spawner.hasmatchingsummoner(user))
		detonate(user)
	else
		user <<"<span class='danger'>Something forces you to avoid touching [src].</span>"
	return

/obj/item/weapon/guardian_bomb/pickup(mob/living/user)
	..()
	if(isliving(user) && user != spawner && user != spawner.summoner && !spawner.hasmatchingsummoner(user))
		detonate(user)
	else
		user <<"<span class='danger'>Something forces you to avoid touching [src].</span>"
	return

/obj/item/weapon/guardian_bomb/attack_hand(mob/user)
	if(isliving(user) && user != spawner && user != spawner.summoner && !spawner.hasmatchingsummoner(user))
		detonate(user)
	else
		user <<"<span class='danger'>Something forces you to avoid touching [src].</span>"
	return

/obj/item/weapon/guardian_bomb/examine(mob/user)
	stored_obj.examine(user)
	if(get_dist(user,src)<=2)
		to_chat(user, "<span class='holoparasite'>It glows with a strange <font color=\"[spawner.namedatum.colour]\">light</font>!</span>")
