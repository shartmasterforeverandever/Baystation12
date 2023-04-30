/*
	Cyborg ClickOn()

	Cyborgs have no range restriction on attack_robot(), because it is basically an AI click.
	However, they do have a range restriction on item use, so they cannot do without the
	adjacency code.
*/

/mob/living/silicon/robot/ClickOn(atom/A, params)
	if(world.time <= next_click)
		return
	next_click = world.time + 1

	var/list/modifiers = params2list(params)
	if (modifiers["ctrl"] && modifiers["alt"] && modifiers["shift"])
		if (CtrlAltShiftClickOn(A))
			return TRUE
	else if (modifiers["ctrl"] && modifiers["alt"])
		if (CtrlAltClickOn(A))
			return TRUE
	else if (modifiers["shift"] && modifiers["ctrl"])
		if (CtrlShiftClickOn(A))
			return TRUE
	else if (modifiers["shift"] && modifiers["alt"])
		if (AltShiftClickOn(A))
			return TRUE
	else if (modifiers["middle"])
		if (MiddleClickOn(A))
			return TRUE
	else if (modifiers["shift"])
		if (ShiftClickOn(A))
			return TRUE
	else if (modifiers["alt"])
		if (AltClickOn(A))
			return TRUE
	else if (modifiers["ctrl"])
		if (CtrlClickOn(A))
			return TRUE

	if(incapacitated())
		return

	if(!canClick())
		return

	face_atom(A) // change direction to face what you clicked on

	if(silicon_camera.in_camera_mode)
		silicon_camera.camera_mode_off()
		if(is_component_functioning("camera"))
			silicon_camera.captureimage(A, usr)
		else
			to_chat(src, SPAN_CLASS("userdanger", "Your camera isn't functional."))
		return

	/*
	cyborg restrained() currently does nothing
	if(restrained())
		RestrainedClickOn(A)
		return
	*/

	var/obj/item/W = get_active_hand()

	// Cyborgs have no range-checking unless there is item use
	if(!W)
		A.add_hiddenprint(src)
		A.attack_robot(src)
		return

	// buckled cannot prevent machine interlinking but stops arm movement
	if( buckled )
		return

	if(W == A)

		W.attack_self(src)
		return

	// cyborgs are prohibited from using storage items so we can I think safely remove (A.loc in contents)
	if(A == loc || (A in loc) || (A in contents))
		// No adjacency checks

		var/resolved = W.resolve_attackby(A, src, params)
		if(!resolved && A && W)
			W.afterattack(A, src, 1, params) // 1 indicates adjacency
		return

	if(!isturf(loc))
		return

	var/sdepth = A.storage_depth_turf()
	if(isturf(A) || isturf(A.loc) || (sdepth != -1 && sdepth <= 1))
		if(A.Adjacent(src)) // see adjacent.dm

			var/resolved = W.resolve_attackby(A, src, params)
			if(!resolved && A && W)
				W.afterattack(A, src, 1, params) // 1 indicates adjacency
			return
		else
			W.afterattack(A, src, 0, params)
			return
	return

//Middle click cycles through selected modules.
/mob/living/silicon/robot/MiddleClickOn(atom/A)
	cycle_modules()
	return

//Give cyborgs hotkey clicks without breaking existing uses of hotkey clicks
// for non-doors/apcs
/mob/living/silicon/robot/CtrlAltClickOn(atom/A)
	if(A.BorgCtrlAltClick(src))
		return
	pointed(A)

/mob/living/silicon/robot/ShiftClickOn(atom/A)
	A.BorgShiftClick(src)

/mob/living/silicon/robot/CtrlClickOn(atom/A)
	return A.BorgCtrlClick(src)

/mob/living/silicon/robot/AltClickOn(atom/A)
	A.BorgAltClick(src)

/mob/living/silicon/robot/CtrlShiftClickOn(atom/A)
	A.BorgCtrlShiftClick(src)

/mob/living/silicon/robot/AltShiftClickOn(atom/A)
	return A.BorgAltShiftClick(src)

/mob/living/silicon/robot/CtrlAltShiftClickOn(atom/A)
	return A.BorgCtrlAltShiftClick(src)

/atom/proc/BorgCtrlAltClick(mob/living/silicon/robot/user) //forward to human click if not overriden
	CtrlAltClick(user)

///obj/machinery/door/airlock/BorgCtrlAltClick()
//	AICtrlAltClick()

/atom/proc/BorgShiftClick(mob/living/silicon/robot/user) //forward to human click if not overriden
	ShiftClick(user)

/obj/machinery/door/airlock/BorgShiftClick()  // Opens and closes doors! Forwards to AI code.
	AIShiftClick()

/atom/proc/BorgCtrlClick(mob/living/silicon/robot/user) //forward to human click if not overriden
	return CtrlClick(user)

/obj/machinery/door/airlock/BorgCtrlClick() // Bolts doors. Forwards to AI code.
	return AICtrlClick()

/obj/machinery/power/apc/BorgCtrlClick() // turns off/on APCs. Forwards to AI code.
	return AICtrlClick()

/obj/machinery/turretid/BorgCtrlClick() //turret control on/off. Forwards to AI code.
	return AICtrlClick()

/atom/proc/BorgAltClick(mob/living/silicon/robot/user)
	AltClick(user)
	return

/obj/machinery/door/airlock/BorgCtrlShiftClick() // Eletrifies doors. Forwards to AI code.
	if (usr.a_intent != I_HELP)
		AICtrlShiftClick()
	else
		..()

/obj/machinery/turretid/BorgAltClick() //turret lethal on/off. Forwards to AI code.
	AIAltClick()

/obj/machinery/atmospherics/binary/pump/BorgAltClick()
	return AltClick()

/atom/proc/BorgCtrlShiftClick(mob/living/silicon/robot/user)
	CtrlShiftClick(user)

/atom/proc/BorgAltShiftClick(mob/living/silicon/robot/user)
	return AIAltShiftClick(user)

/atom/proc/BorgCtrlAltShiftClick(mob/living/silicon/robot/user)
	return AICtrlAltShiftClick(user)

/*
	As with AI, these are not used in click code,
	because the code for robots is specific, not generic.

	If you would like to add advanced features to robot
	clicks, you can do so here, but you will have to
	change attack_robot() above to the proper function
*/
/mob/living/silicon/robot/UnarmedAttack(atom/A)
	A.attack_robot(src)

/mob/living/silicon/robot/RangedAttack(atom/A, params)
	A.attack_robot(src)
	return TRUE

/**
 * Called when a silicon robot mob clicks on an atom.
 *
 * **Parameters**:
 * - `user` - The mob clicking on the atom.
 */
/atom/proc/attack_robot(mob/user as mob)
	attack_ai(user)
	return
