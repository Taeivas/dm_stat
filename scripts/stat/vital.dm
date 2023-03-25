stat
	vital
		New()
			. = ..()
			UpdateVital(current)
		var
			tmp
				pause_vital = FALSE
				recovery = FALSE
			auto_adjust = TRUE
			current = 0
			stat
				recovery_rate = 1
				current_min
				current_max
			recovery_delay = 10
		Update()
			. = value
			..()
			if(. != value && auto_adjust)
				src >>= value - .

		operator""()
			. = "[name]: [current]/[value]"
			if(desc != null)
				. += "\n\t[desc]"
		proc
			Recovery()
				set waitfor = FALSE
				if(recovery)
					return FALSE
				recovery = TRUE
				while(recovery && current < value)
					sleep(recovery_delay)
					src >>= min(recovery_rate, value - recovery_rate)
					if(current >= value)
						break
				recovery = FALSE
			UpdateVital(old_current)
				if(pause_vital)
					return FALSE
				else
					if(old_current != current)
						if(locs && locs.len)
							for(var/atom/a in locs)
								a.OnUpdateVital(src, old_current, current)
						Recovery()
					return TRUE
			LimitVital(current)
				if(current_min != null)
					if(isnum(current_min))
						current = max(current_min, current)
					else if(istype(current_min, /stat))
						current = max(current_min:value, current)
				if(current_max != null)
					if(isnum(current_max))
						current = min(current_max, current)
					else if(istype(current_max, /stat))
						current = min(current_max:value, current)
				return current
			operator<<=(x)
				. = current
				if(isnum(x))
					current -= x
					current = LimitVital(current)
				else if(islist(x))
					pause_vital = TRUE
					for(var/v in x)
						src <<= v
					pause_vital = FALSE
				else if(istype(x, /stat))
					src <<= x:value
				if(current != .)
					UpdateVital(.)
			operator>>=(x)
				. = current
				if(isnum(x))
					current += x
					current = LimitVital(current)
				else if(islist(x))
					pause_vital = TRUE
					for(var/v in x)
						src >>= v
					pause_vital = FALSE
				else if(istype(x, /stat))
					src >>= x:value
				if(current != .)
					UpdateVital(.)