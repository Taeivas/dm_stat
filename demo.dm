#define DEBUG_VAR(v) world.log << "[#v] = [v]"

world
	Tick()
		stat_vital_recovery_tick()

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
			src << vital
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
			src << "[__PROC__] :: ([s.value]) : " + json_encode(args)
		StatChange(event, stat/s, old_value)
			src << "[__PROC__] :: ([s.value]) : " + json_encode(args)
		StrictChange()
			src << "[__PROC__] :: " + json_encode(args)
	verb
		Test()
			// Increment stat base by 1
			//stat0 += 1
			//stat1 += 2
			vital += 1
		Dec()
			vital <<= 5