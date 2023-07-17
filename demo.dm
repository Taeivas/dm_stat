#define DEBUG_VAR(v) world.log << "[#v] = [v]"

#if DM_VERSION < 515
proc/tick_loop()
	for()
		stat_vital_recovery_tick()
		sleep(world.tick_lag)
world
	New()
		. = ..()
		tick_loop()
#else
world
	Tick()
		stat_vital_recovery_tick()
#endif

mob
	New()
		. = ..()
		// Bind stats
		stat0 &= stat1
		vital &= stat0
		// Add events
		stat0.On("change", src, "StatChange")
		stat1.On("change", src, "StatChange")
		vital.On("change", src, "StatChange")
		vital.On("change:current", src, "StatChange")
		//vital.On("change:current", src, "StrictChange", list(1, 2, 3), strict = TRUE)
		spawn(1)
			vital %= new /stat ("multiplier", 10)
			DEBUG_VAR(vital.multiplier)

			#if DM_VERSION < 515
			src << vital.Stringify()
			#else
			src << vital
			#endif
		spawn(25)
			vital %= 1
			DEBUG_VAR(vital.multiplier)
			vital.Update()
			DEBUG_VAR(vital)
	var
		stat // Create stat with value limitations to current and base
			stat0 = new ("stat0", 1) //stat {value_limit = new (2, 5); base_limit = new (1, 10)}
			stat1 = new ("stat1", 1)
			vital
				vital = new /stat/vital {base = 1} ("vital")
	proc
		StatUpdate(event, stat/s)
			#if DM_VERSION < 515
			var/proc_type =  .....
			#else
			var/proc_type = __PROC__
			#endif
			src << "[proc_type] :: ([s.value]) : " + json_encode(args)
		StatChange(event, stat/s, old_value)
			#if DM_VERSION < 515
			var/proc_type =  .....
			#else
			var/proc_type = __PROC__
			#endif
			src << "[proc_type] :: ([s.value]) : " + json_encode(args)
		StrictChange()
			#if DM_VERSION < 515
			var/proc_type =  .....
			#else
			var/proc_type = __PROC__
			#endif
			src << "[proc_type] :: " + json_encode(args)
	verb
		Test()
			// Increment stat base by 1
			stat0 += 1
			stat1 += 1
			vital += 1
		Dec()
			vital <<= 5
