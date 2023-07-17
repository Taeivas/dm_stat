/*
 * Represents a vital statistic.
 *
 * The `New()` method initializes a new vital statistic object.
 * If the `recovery_rate` is set, the vital statistic is added to the `stat_vital_recovery` global variable.
 *
 * Properties:
 * - `current`: Current value of the vital statistic.
 * - `stat/limit/current_limit`: Limit of the current value. Automatically adjusted if set.
 * - `auto_adjust`: Flag indicating whether the `current` value should be automatically adjusted.
 * - `recovery_delay`: Time delay for recovery.
 * - `tmp`: Temporary variable.
 * - `stat/recovery_rate`: Recovery rate of the vital statistic.
 *
 * Methods:
 * - `Update()`: Updates the vital statistic value. If the value changes and `auto_adjust` is enabled, adjusts the `src` accordingly.
 *   If the `recovery_rate` is set, adds the vital statistic to the `stat_vital_recovery` global variable.
 * - `Recovery()`: Initiates the recovery process for the vital statistic.
 * - `operator""()`: Returns a string representation of the vital statistic.
 * - `operator<<=(stat/s)`: Decreases the current value by `s`. Handles different types of `s`.
 * - `operator>>=(stat/s)`: Increases the current value by `s`. Handles different types of `s`.
 */
stat
	vital
		New()
			. = ..()
			if(recovery_rate)
				#if DM_VERSION < 515
				global.stat_vital_recovery |= src
				#else
				::stat_vital_recovery |= src
				#endif
		var
			current = 0
			stat/limit/current_limit
			auto_adjust = TRUE

			recovery_delay = 10
			tmp
				recovery_next
			stat
				recovery_rate = 1
		Update()
			. = value
			..()
			if(. != value && auto_adjust)
				src >>= value - .
			else
				if(recovery_rate)
					#if DM_VERSION < 515
					global.stat_vital_recovery |= src
					#else
					::stat_vital_recovery |= src
					#endif
		#if DM_VERSION < 515
		Stringify()
			return "[name]: [current]/[value]"
		#else
		operator""()
			return "[name]: [current]/[value]"
		#endif
		proc
			Recovery()
				if(recovery_next == null)
					recovery_next = world.time + recovery_delay
				else if(recovery_next <= world.time)
					src >>= min(value - current, isnum(recovery_rate) ? recovery_rate : recovery_rate.value)
					recovery_next = world.time + recovery_delay
					if(current >= value)
						recovery_next = null
						#if DM_VERSION < 515
						global.stat_vital_recovery -= src
						#else
						::stat_vital_recovery -= src
						#endif
			operator<<=(stat/s)
				. = current
				if(isnum(s))
					current -= s
				else if(istype(s, /stat))
					current -= s.value
				else if(islist(s))
					pause_update = TRUE
					for(var/a in s)
						src <<= a
					pause_update = FALSE
				if(current_limit)
					current = current_limit.Clamp(current)
				if(pause_update)
				else
					if(. != current)
						if(events && events["change:current"])
							for(var/stat/event/e in events["change:current"])
								e.Call("change:current", src, .)
					if(current < value && recovery_rate)
						#if DM_VERSION < 515
						global.stat_vital_recovery |= src
						#else
						::stat_vital_recovery |= src
						#endif
			operator>>=(stat/s)
				. = current
				if(isnum(s))
					current += s
				else if(istype(s, /stat))
					current += s.value
				else if(islist(s))
					pause_update = TRUE
					for(var/a in s)
						src >>= a
					pause_update = FALSE
				if(current_limit)
					current = current_limit.Clamp(current)
				if(pause_update)
				else
					if(. != current)
						if(events && events["change:current"])
							for(var/stat/event/e in events["change:current"])
								e.Call("change:current", src, .)
					if(current < value && recovery_rate)
						#if DM_VERSION < 515
						global.stat_vital_recovery |= src
						#else
						::stat_vital_recovery |= src
						#endif